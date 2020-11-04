
el = document.getElementById("marker")

function UpdateMarkers(json){
	var obj = JSON.parse(json)
	
	for (var i = 0; i<json.dist.length();i++) {
		UpdateMarker(json.cords[i].x, json.cords[i].y, json.dist[i]);
	}
}

function ShowMarker(show){
	if (show) {
		el.style.display = 'block';
	} else {
		el.style.display = 'none';
	}
}

function UpdateMarker(x, y, dist){
	el.style.left = x + "px";
	el.style.top = y + "px";

	el.style.width = dist/70 * 20 +"px";
	el.style.height = dist/70 * 20  +"px";
}

