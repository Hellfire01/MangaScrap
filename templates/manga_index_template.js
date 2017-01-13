#####tab#####

function displayData(id) {
	var buffer = "";

	buffer += "<h3 class=\"details-title\">name :</h3>";
	buffer += data[id][0] + "<br />";
	buffer += "<h3 class=\"details-title\">other names :</h3>";
	buffer += data[id][1].replace(/###guillemet###/g, '"') + "<br />";
	buffer += "<h3 class=\"details-title\">author :</h3>";
	buffer += data[id][3] + "<br />";
	buffer += "<h3 class=\"details-title\">artist :</h3>";
	buffer += data[id][4] + "<br />";
	buffer += "<h3 class=\"details-title\">status :</h3>";
	buffer += data[id][5] + "<br />";
	buffer += "<h3 class=\"details-title\">genres :</h3>";
	buffer += data[id][6] + "<br />";
	buffer += "<h3 class=\"details-title\">description :</h3>";
	buffer += ((data[id][2] === "") ? "/" : data[id][2].replace(/###guillemet###/g, '"')) + "<br />";
	document.getElementById("details").innerHTML = buffer;
}

function clearData() {
//	document.getElementById("details").innerHTML = "";
}

function stay_on_top() {
  var el = document.getElementById("details"); 
  var isPositionFixed = el.style.position == 'fixed';
	var top = 180;

  if (window.pageYOffset > top && !isPositionFixed) {
		el.style.position = "fixed";
		el.style.top = "0px";
	}
  if (window.pageYOffset < top && isPositionFixed) {
		el.style.position = "absolute";
		el.style.top = top + "px";
  }
}

window.onscroll = stay_on_top;
