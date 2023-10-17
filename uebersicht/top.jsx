import { withDefaultStyles, withPath } from './lib'

export const command = withPath`ps -arcwwwxo "command %cpu %mem" | head -11 | tail -10`

export const refreshFrequency = 10 * 1000

export const className = withDefaultStyles({ left: '40px', top: '40px' })

export const render = ({ output }) => {
  return (
    <pre dangerouslySetInnerHTML={{ __html: output }} />
  )
}