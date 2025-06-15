
document.addEventListener("DOMContentLoaded", function() {
    setup(htmlComponent);
});

function setup(htmlComponent) {
    const form = document.getElementById('form');
    form.addEventListener('submit', function(event) {
        event.preventDefault();

        const file = document.getElementById('file').files[0];
        if (!file) {
            alert('Selecciona un archivo.');
            return;
        }

        const reader = new FileReader();
        reader.onload = function() {
            const base64String = reader.result.split(',')[1];
            // Enviar la imagen a MATLAB vía htmlComponent
            htmlComponent.sendEventToMATLAB('imagenSubida', { imagen: base64String });

            // Mostrar la imagen original en la página
            document.getElementById('originalImage').src = reader.result;
        };
        reader.readAsDataURL(file);
    });

    // Función para recibir la imagen procesada desde MATLAB
    htmlComponent.addEventListener("ImagenProcesada", function(event) {
        const base64String = event.Data;

        // transformar la cadena base64 en una imagen y mostrarla
        const img = new Image();
        img.src = "data:image/jpeg;base64," + base64String;
        document.getElementById("resultImage").src = img.src;
    });

    htmlComponent.addEventListener("numeroDeObjetos", function(event) {
        const numeroDeObjetos = event.Data;
        document.getElementById("numObjetos").textContent = numeroDeObjetos;
    });
}