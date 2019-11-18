// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// the compiled file.
//
// WARNING: THE FIRST BLANK LINE MARKS THE END OF WHAT'S TO BE PROCESSED, ANY BLANK LINE SHOULD
// GO AFTER THE REQUIRES BELOW.
//
//= require jquery
//= require jquery_ujs
//= require foundation
//= require_tree .

$(document).ready(function () {

  $(document).foundation();

  // MAKE THE CHARTS
  // ---------------------------------------------------------
  $('.widget .chart').each(function(){
    var monthNames = [ "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec", "Jan" ];
    var chart_id = $(this).attr('id');
    var responses = $(this).data('numbers');
    var labels = $(this).data('labels');

    var data = [];
    for (var i = 0; i < labels.length; i++) {
        var obj = {}
        obj.month = labels[i];
        obj.value = responses[i];
        data.push(obj);
    }

    new Morris.Area({
      // ID of the element in which to draw the chart.
      element: chart_id,
      // Chart data records -- each entry in this array corresponds to a point on
      // the chart.
      data: data,
      // The name of the data record attribute that contains x-values.
      xkey: 'month',
      xLabels: 'month',
      xLabelFormat: function (x) { return monthNames[x.getMonth()]; },
      // A list of names of data record attributes that contain y-values.
      ykeys: ['value'],
      // Labels for the ykeys -- will be displayed when you hover over the
      // chart.
      labels: ['Value'],
      hideHover: 'auto',
      hoverCallback: function (index, options, content) {
        var row = options.data[index];
        var month = new Date(row.month);
        var content = content.replace(/(\r\n|\n|\r)/gm,"").replace(/ +(?= )/g,'');
        return content.replace(row.month, monthNames[month.getMonth()]).replace("Value: ", '');
      },
      axes: false,
      grid: false,
      fillOpacity: 0.2,
      gridStrokeWidth: 0.1,
      resize: true,
      padding: 8,
      lineColors: ['#027ab8']
    });

  });

  // SCROLL
  // ---------------------------------------------------------
  var $root = $('html, body');
  $('a').click(function() {
    var href = $.attr(this, 'href');
    $root.animate({
        scrollTop: $(href).offset().top
    }, 500, function () {
        window.location.hash = href;
    });
    return false;
  });


});