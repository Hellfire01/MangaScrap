function fix(el, top, margin) {
    var isPositionFixed = el.style.position == 'fixed';

    if (window.pageYOffset > top - margin && !isPositionFixed) {
        el.style.position = "fixed";
        el.style.top = margin + "px";
    }
    if (window.pageYOffset < top - margin && isPositionFixed) {
        el.style.position = "absolute";
        el.style.top = top + "px";
    }
}

function stay_on_top() {
    fix(document.getElementById("chapter-data"), 170, 0);
    fix(document.getElementById("float-right"), 458, 287);
}

window.onscroll = stay_on_top;
