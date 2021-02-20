import { withPath, withDefaultStyles } from './lib'

const INDEX_SYMBOLS = ['ES=F', 'YM=F', 'NQ=F', 'RTY=F']

export const command = `curl -s "https://query1.finance.yahoo.com/v7/finance/quote?lang=en-US&region=US&corsDomain=finance.yahoo.com&fields=regularMarketChangePercent&symbols=${INDEX_SYMBOLS.join(',')}"`

export const refreshFrequency = 2 * 60 * 1000

export const className = withDefaultStyles()

export const render = ({ output }) => {
  try {
    return JSON.parse(output).quoteResponse.result.map((data, i) => {
      const isUp = data.regularMarketChangePercent > 0
      const indicator = isUp ? '↗' : '↘'
      const className = isUp ? 'bg-green' : 'bg-red'

      return <pre key={i} className={`${className} white`} style={{ padding: '2px 5px', marginBottom: '1px' }}>
        {data.symbol}{'\t'}{indicator} {data.regularMarketChangePercent.toFixed(2)}%
      </pre>
    })
  } catch (err) {
    return <div className='white'>Error fetching data: {err.message}</div>
  }
}