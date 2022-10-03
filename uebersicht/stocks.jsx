import { withPath, withDefaultStyles } from './lib'

export const command = withPath`~/.cargo/bin/ticker $(cat ~/Library/Mobile\\ Documents/com~apple~CloudDocs/Data/Code/ticker.conf) | aha --stylesheet --no-header`

export const refreshFrequency = 20 * 1000

export const className = withDefaultStyles({ left: '185px' }, `
  .bold { color: white }
`)

export const render = ({ output }) => {
  return (
    <pre dangerouslySetInnerHTML={{ __html: output }} />
  )
}