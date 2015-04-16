function getFilteredAndSortedData(a,b){var c=_.chain(a);return b&&(c=c.filter(function(a){return a.acayear===b&&null!==a.wait_time})),c=c.map(function(a){return[new Date(a.timestamp).getTime(),a.wait_time]}).sort(function(a,b){return a[0]-b[0]}).value()}function makeGraph1(){$("#graph1").highcharts("StockChart",{title:{text:"Average Montly SafeRide Wait Times"},subtitle:{text:"Data gathered from @NUSafeRide Twitter account"},credits:{enabled:!1},exporting:{enabled:!1},rangeSelector:{enabled:!1},scrollbar:{enabled:!1},navigator:{enabled:!1},plotOptions:{series:{dataGrouping:{approximation:"average",enabled:!0,forced:!0,units:[["month",[1]]]},animation:!1,states:{hover:{enabled:!1}}}},series:graph1Series})}function makeGraph2(){$("#graph2").highcharts({title:{text:"Average Hourly SafeRide Wait Times"},subtitle:{text:"Data gathered from @NUSafeRide Twitter account"},credits:{enabled:!1},exporting:{enabled:!1},rangeSelector:{enabled:!1},scrollbar:{enabled:!1},navigator:{enabled:!1},tooltip:{shared:!0},plotOptions:{series:{animation:!1,states:{hover:{enabled:!1}}}},series:graph2Series})}var saferideSeries=null;$(document).ready(function(){-1!=window.location.href.indexOf("graph1")&&$.get("data/graph1.json",function(a){graph1Series=[{name:"2012-2013",data:getFilteredAndSortedData(a,"2012-2013"),marker:{enabled:!0}},{name:"2013-2014",data:getFilteredAndSortedData(a,"2013-2014"),marker:{enabled:!0}},{name:"Summer 2014",data:getFilteredAndSortedData(a,"Summer 2014"),marker:{enabled:!0}},{name:"2014-2015",data:getFilteredAndSortedData(a,"2014-2015"),marker:{enabled:!0}}],makeGraph1()}),-1!=window.location.href.indexOf("graph2")&&$.get("data/graph2.json",function(a){graph2Series=[{name:"Wait Times",type:"spline",data:_.map(a,function(a){return[a.hour,a.mean]}),marker:{enabled:!0},tooltip:{pointFormat:'<span style="font-weight: bold; color: {series.color}">{series.name}</span>: <b>{point.y:.1f} minutes</b> '}},{name:"Wait Times Error",type:"errorbar",data:_.map(a,function(a){return[a.hour,a.lci,a.uci]}),tooltip:{pointFormat:"(error range: {point.low:.2f}-{point.high:.2f})<br/>"}}],makeGraph2()})});