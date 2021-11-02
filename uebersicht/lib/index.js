const PATH = "/opt/homebrew/bin:$PATH"

export function withPath (command) {
  return `PATH=${PATH}; ${command}`
}

export function withDefaultStyles ({
    top,
    left,
    right,
    bottom,
    fontFamily = 'Iosevka Term SS05',
    fontSize = '12px'
  } = {},
  custom = ''
  ) {
    return `
    ${top !== undefined || bottom === undefined ? `top: ${top || '20px'}` : ''};
    ${left !== undefined || right === undefined ? `left: ${left || '20px'}` : ''};
    ${right !== undefined ? `right: ${right}` : ''};
    ${bottom !== undefined ? `bottom: ${bottom}` : ''};

    * {
      padding: 0;
      margin: 0;
      font-size: ${fontSize};
      font-family: ${fontFamily};
    }

    .white { color: #fff; }
    .green { color: #2f731a; }
    .red { color: #a63333; }
    .blue { color: #4269f5; }
    .yellow { color: #f5da42 }

    .bg-white { background-color: #fff; }
    .bg-green { background-color: #2f731a; }
    .bg-red { background-color: #a63333; }

    ${custom}
  `
}
