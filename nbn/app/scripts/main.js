var saferideSeries = null;

function getFilteredAndSortedData(data, filter) {
  var d = _.chain(data)
    .filter(function(x) {
      return x.acayear === filter && x.wait_time !== null;
    })
    .map(function(x) {
        return [new Date(x.timestamp).getTime(), x.wait_time];
    })
    .sort(function(a, b) {
      return a[0] - b[0];
    })
    .value();
  return d;
}

function makeSaferideGraph() {
  $('#container').highcharts('StockChart', {

    title: { text: 'Average Montly Saferide Wait Times' },
    subtitle: { text: 'Data gathered from @adgdsgasd Twitter account' },

    credits: { enabled: false },
    // tooltip: { enabled: false },
    exporting: { enabled: false },
    rangeSelector: { enabled: false },
    scrollbar: { enabled: false },
    navigator: { enabled: false },

    plotOptions: {
      series: {
        dataGrouping: {
          approximation: 'average',
          enabled: true,
          forced: true,
          units: [
            ['month',[1]]
          ]
        },
        animation: false,
        states: {
            hover: { enabled: false }
        }
      }
    },

    series: saferideSeries

  });
}

$(document).ready(function() {
  $.get('data/graph1.json', function(data) {

    saferideSeries = [
      {
        name: '2012-2013',
        data: getFilteredAndSortedData(data, '2012-2013')
      }, {
        name: '2013-2014',
        data: getFilteredAndSortedData(data, '2013-2014')
      }, {
        name: 'Summer 2014',
        data: getFilteredAndSortedData(data, 'Summer 2014')
      }, {
        name: '2014-2015',
        data: getFilteredAndSortedData(data, '2014-2015')
      }
    ];

    makeSaferideGraph();
  });
});
