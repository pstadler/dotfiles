const PATH = "/opt/homebrew/bin:$PATH"

export function withPath (command) {
  return `PATH=${PATH}; ${command}`
}

export function withDefaultStyles ({
    top,
    left,
    right,
    bottom,
    fontFamily = 'Iosevka Term SS12',
    fontSize = '12px',
    fontWeight = '700',
    color = 'rgba(255, 255, 255, 0.7)'
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
      font-weight: ${fontWeight};
      color: ${color};
    }

    .white { color: #fff; }
    .green { color: rgb(113, 181, 156); }
    .red { color: rgb(255, 139, 139); }
    .blue { color: rgb(85, 172, 238); }
    .yellow { color: #f5da42 }

    .bg-white { background-color: #fff; }
    .bg-green { background-color: rgb(10, 111, 43); }
    .bg-red { background-color: rgb(204, 58, 58); }

    ${custom}
  `
}
