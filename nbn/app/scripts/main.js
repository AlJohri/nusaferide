var saferideSeries = null;

function getFilteredAndSortedData(data, filter) {
  var d = _.chain(data);

  if (filter) {
    d = d.filter(function(x) {
      return x.acayear === filter && x.wait_time !== null;
    });
  }

  d = d.map(function(x) {
        return [new Date(x.timestamp).getTime(), x.wait_time];
    })
    .sort(function(a, b) {
      return a[0] - b[0];
    })
    .value();

  return d;
}

function makeGraph1() {
  $('#graph1').highcharts('StockChart', {

    title: { text: 'Average Montly SafeRide Wait Times' },
    subtitle: { text: 'Data gathered from @NUSafeRide Twitter account' },

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

    series: graph1Series

  });
}

function makeGraph2() {

  $('#graph2').highcharts({

    title: { text: 'Average Hourly SafeRide Wait Times' },
    subtitle: { text: 'Data gathered from @NUSafeRide Twitter account' },

    credits: { enabled: false },
    // tooltip: { enabled: false },
    exporting: { enabled: false },
    rangeSelector: { enabled: false },
    scrollbar: { enabled: false },
    navigator: { enabled: false },
    tooltip: { shared: true },
    plotOptions: {
      series: {
        animation: false,
        states: {
            hover: { enabled: false }
        }
      }
    },

    series: graph2Series

  });


}

$(document).ready(function() {
  if (window.location.href.indexOf("graph1") != -1) {
    $.get('data/graph1.json', function(data) {

      graph1Series = [
        {
          name: '2012-2013',
          data: getFilteredAndSortedData(data, '2012-2013'),
          marker: {enabled: true }
        }, {
          name: '2013-2014',
          data: getFilteredAndSortedData(data, '2013-2014'),
          marker: {enabled: true }
        }, {
          name: 'Summer 2014',
          data: getFilteredAndSortedData(data, 'Summer 2014'),
          marker: {enabled: true }
        }, {
          name: '2014-2015',
          data: getFilteredAndSortedData(data, '2014-2015'),
          marker: {enabled: true }
        }
      ];
      makeGraph1();
    });
  }

  if (window.location.href.indexOf("graph2") != -1) {

    $.get('data/graph2.json', function(data) {
      graph2Series = [
        {
          name: 'Wait Times',
          type: 'spline',
          data: _.map(data, function(x) {return [x.hour, x.mean] }),
          marker: {enabled: true },
          tooltip: {
              pointFormat: '<span style="font-weight: bold; color: {series.color}">{series.name}</span>: <b>{point.y:.1f} minutes</b> '
          }
        },
        {
          name: 'Wait Times Error',
          type: 'errorbar',
          data: _.map(data, function(x) {return [x.hour, x.lci, x.uci] }),
          tooltip: {
              pointFormat: '(error range: {point.low:.2f}-{point.high:.2f})<br/>'
          }
        }
      ];
      makeGraph2();
    });
  }

});
