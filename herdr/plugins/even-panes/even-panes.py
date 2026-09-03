import fcntl
import json
import os
import socket
import sys
import time

SOCKET: str = os.environ.get("HERDR_SOCKET_PATH") or ""
if not SOCKET:
    raise SystemExit("No active Herdr socket")
LOCK_PATH = "/tmp/herdr-even-panes.lock"
RATIO_TOLERANCE = 0.005


def request(method, params, request_id="even-panes"):
    payload = (
        json.dumps(
            {"id": request_id, "method": method, "params": params},
            separators=(",", ":"),
        )
        + "\n"
    )
    with socket.socket(socket.AF_UNIX, socket.SOCK_STREAM) as connection:
        connection.connect(SOCKET)
        connection.sendall(payload.encode())
        response = b""
        while not response.endswith(b"\n"):
            chunk = connection.recv(65536)
            if not chunk:
                break
            response += chunk

    result = json.loads(response)
    if "error" in result:
        raise RuntimeError(result["error"].get("message", result["error"]))
    return result


def panes(root):
    if root.get("type") == "pane":
        return [root["pane_id"]]
    return panes(root["first"]) + panes(root["second"])


def split_requests(root, tab_id, path=()):
    if root.get("type") != "split":
        return 1, []

    left_count, left_requests = split_requests(root["first"], tab_id, path + (False,))
    right_count, right_requests = split_requests(root["second"], tab_id, path + (True,))
    total = left_count + right_count
    desired = left_count / total
    requests = left_requests + right_requests
    if abs(desired - root["ratio"]) > RATIO_TOLERANCE:
        path_id = "".join("1" if side else "0" for side in path)
        requests.append(
            {
                "id": "even-panes-ratio-" + path_id,
                "method": "layout.set_split_ratio",
                "params": {"tab_id": tab_id, "path": list(path), "ratio": desired},
            }
        )
    return total, requests


def balance(tab_id, layout=None):
    layout = layout or request("layout.export", {"tab_id": tab_id})["result"]["layout"]
    _, changes = split_requests(layout["root"], tab_id)
    if not changes:
        return
    for change in changes:
        request(change["method"], change["params"], change["id"])


def applied(snapshot, event):
    event_type = event["type"]
    pane_ids = {
        pane["pane_id"]
        for layout in snapshot["result"]["snapshot"]["layouts"]
        for pane in layout.get("panes", [])
    }
    if event_type in ("pane_closed", "pane_exited"):
        return event["pane_id"] not in pane_ids
    if event_type == "pane_moved":
        return (
            event["pane"]["pane_id"] in pane_ids
            and event["previous_pane_id"] not in pane_ids
        )
    return True


def wait_for_layout(event, event_type):
    for _ in range(50):
        layout = request("layout.export", {"tab_id": event["pane"]["tab_id"]})[
            "result"
        ]["layout"]
        if event["pane"]["pane_id"] in panes(layout["root"]):
            return layout
        time.sleep(0.01)
    raise RuntimeError(f"pane layout did not reflect {event_type}")


def main():
    raw_event = json.loads(os.environ["HERDR_PLUGIN_EVENT_JSON"])
    event = raw_event.get("data", raw_event)
    event_type = event["type"]

    if event_type == "pane_created":
        tab_ids = [event["pane"]["tab_id"]]
        wait_for_layout(event, event_type)
    else:
        for _ in range(50):
            snapshot = request("session.snapshot", {})
            if applied(snapshot, event):
                break
            time.sleep(0.01)
        else:
            raise RuntimeError(f"pane layout did not reflect {event_type}")

        workspace_ids = set()
        if event_type in ("pane_closed", "pane_exited"):
            workspace_ids.add(event["workspace_id"])
        elif event_type == "pane_moved":
            workspace_ids.update(
                (event.get("previous_workspace_id"), event["pane"].get("workspace_id"))
            )
        tab_ids = [
            layout["tab_id"]
            for layout in snapshot["result"]["snapshot"]["layouts"]
            if layout.get("workspace_id") in workspace_ids
        ]

    with open(LOCK_PATH, "w") as lock:
        fcntl.flock(lock, fcntl.LOCK_EX)
        for tab_id in dict.fromkeys(tab_ids):
            balance(tab_id)


try:
    main()
except (KeyError, OSError, RuntimeError, json.JSONDecodeError) as error:
    print(error, file=sys.stderr)
    raise SystemExit(1)
