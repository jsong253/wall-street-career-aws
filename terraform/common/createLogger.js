const createLogger = caller => {
    return (event, obj = {}) => {
      const report = { event: `wall-street/${caller}/${event}`, ...obj }
      if (report.critical || report.error) { console.error(report) } else { console.log(report) }
    }
  }
  module.exports ={createLogger}