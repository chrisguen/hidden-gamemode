
el = document.getElementById("marker")
pb = document.getElementById("progbar")

function UpdateMarkers(json){
	console.log(json);
	var obj = JSON.parse(json)

	if (obj.dist.length() < 1) {
		console.log("return");
		return;
	}

	for (var i = 1; i <= json.dist.length();i++) {
		UpdateMarker(json.cords[i].x, json.cords[i].y, json.dist[i]);
		console.log("update");
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