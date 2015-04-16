var graph1 = null;
var seriesGraph1 = null;

function to_date(datestring) {
    // return Date.parse(datestring);
    var parts = datestring.split('-');
    return new Date(parts[0], parts[1] - 1, parts[2]).getTime();
}

function desc_start_time(x) {
    return new Date(x[0]).getTime();
}

function makeGraph1() {

    $('#container').highcharts({

        title: { text: 'Global temperature change' },
        subtitle: { text: 'Data input from CSV' },

        // credits: { enabled: false },
        // tooltip: { enabled: false },
        // exporting: { enabled: false },
        plotOptions: {
            series: {
                dataGrouping: {
                    approximation: 'mean',
                    enabled: true,
                    forced: true,
                }
                animation: false,
                states: {
                    hover: { enabled: false }
                }
            }
        },

        series: seriesGraph1

    });

}


$(function () {

    $.get("data/graph1.json", function(data) {
        graph1 = data;
        seriesGraph1 = [
            {
                name: "2012-2013",
                data: _.chain(graph1).filter(function(x) { return x.acayear == "2012-2013"}).map(function(x) {return [to_date(x.month), x.avg_time]}).sortBy(desc_start_time).value(),
            },
            {
                name: "2013-2014",
                data: _.chain(graph1).filter(function(x) { return x.acayear == "2013-2014"}).map(function(x) {return [to_date(x.month), x.avg_time]}).sortBy(desc_start_time).value(),
            },
            {
                name: "Summer 2014",
                data: _.chain(graph1).filter(function(x) { return x.acayear == "Summer 2014"}).map(function(x) {return [to_date(x.month), x.avg_time]}).sortBy(desc_start_time).value(),
            },
            {
                name: "2014-2015",
                data: _.chain(graph1).filter(function(x) { return x.acayear == "2014-2015"}).map(function(x) {return [to_date(x.month), x.avg_time]}).sortBy(desc_start_time).value(),
            }
        ]

        makeGraph1();
    });

});
