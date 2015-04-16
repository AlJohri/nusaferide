var graph1 = null;

function makeGraph1() {

    var series = [
        {
            name: "2012-2013",
            data: _.chain(graph1).filter(function(x) { return x.acayear == "2012-2013"}).map(function(x) {return [Date.parse(x.month), x.avg_time]}).value(),
        },
        {
            name: "2013-2014",
            data: _.chain(graph1).filter(function(x) { return x.acayear == "2013-2014"}).map(function(x) {return [Date.parse(x.month), x.avg_time]}).value(),
        },
        {
            name: "Summer 2014",
            data: _.chain(graph1).filter(function(x) { return x.acayear == "Summer 2014"}).map(function(x) {return [Date.parse(x.month), x.avg_time]}).value(),
        },
        {
            name: "2014-2015",
            data: _.chain(graph1).filter(function(x) { return x.acayear == "2014-2015"}).map(function(x) {return [Date.parse(x.month), x.avg_time]}).value(),
        }
    ]

    debugger;

    $('#container').highcharts({

        title: { text: 'Global temperature change' },
        subtitle: { text: 'Data input from CSV' },

        credits: { enabled: false },
        tooltip: { enabled: false },
        exporting: { enabled: false },
        plotOptions: {
            series: {
                animation: false,
                states: {
                    hover: { enabled: false }
                }
            }
        },

        series: series

    });

}


$(function () {

    $.get("data/graph1.json", function(data) {
        graph1 = data;
        makeGraph1();
    });

});
