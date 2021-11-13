function createNoteWithOSM(lon, lat, text) {
    $.post("https://master.apis.dev.openstreetmap.org/api/0.6/notes.json", {
        lon: lon,
        lat: lat,
        text: text
    }, function(data) {
        console.log(data)
    });
}
