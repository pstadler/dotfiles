import { withPath, withDefaultStyles } from './lib'

const SYMBOLS = ['ES=F', 'YM=F', 'NQ=F', 'RTY=F', 'QQQ', '^SPX', '^DJI', 'usdchf=X']

export const command = `curl -s "https://query1.finance.yahoo.com/v7/finance/quote?lang=en-US&region=US&corsDomain=finance.yahoo.com&fields=regularMarketChangePercent,preMarketChangePercent&symbols=${SYMBOLS.join(',')}"`

export const refreshFrequency = 2 * 60 * 1000

export const className = withDefaultStyles({}, `
  .row {
    padding: 2px 5px;
    margin-bottom: 1px;
  }

  .price {
    text-align: right;
    float: right;
    width: 60px;
  }
`)

export const render = ({ output }) => {
  try {
    return JSON.parse(output).quoteResponse.result.map((data, i) => {
      const className = data.regularMarketChangePercent >= 0 ? 'bg-green' : 'bg-red'
      const isOpen = data.marketState === 'REGULAR'

      return <div key={i} className={`row white ${className}`} style={{ opacity: isOpen ? '1' : 0.5 }}>
        {data.symbol}
        <span className='price'>
          {data.regularMarketChangePercent.toFixed(2)}%
        </span>
      </div>
    })
  } catch (err) {
    return <div className='red bg-white'>Error fetching data: {err.message}</div>
  }
}
