/*
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
*/
