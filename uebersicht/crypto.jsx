import { withDefaultStyles, withPath } from './lib'

export const command = withPath`~/Dropbox/Code/crypto.sh`

export const refreshFrequency = 60 * 1000

export const className = withDefaultStyles({ left: '480px' })

export const render = ({ output }) => {
  return (
    <pre dangerouslySetInnerHTML={{ __html: output }} />
  )
}