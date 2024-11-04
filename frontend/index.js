import { backend } from 'declarations/backend';

const dropArea = document.getElementById('dropArea');
const fileInput = document.getElementById('fileInput');
const previewImage = document.getElementById('previewImage');
const apiKeyInput = document.getElementById('apiKey');
const detectButton = document.getElementById('detectButton');
const resultDiv = document.getElementById('result');

['dragenter', 'dragover', 'dragleave', 'drop'].forEach(eventName => {
    dropArea.addEventListener(eventName, preventDefaults, false);
});

function preventDefaults(e) {
    e.preventDefault();
    e.stopPropagation();
}

['dragenter', 'dragover'].forEach(eventName => {
    dropArea.addEventListener(eventName, highlight, false);
});

['dragleave', 'drop'].forEach(eventName => {
    dropArea.addEventListener(eventName, unhighlight, false);
});

function highlight() {
    dropArea.classList.add('highlight');
}

function unhighlight() {
    dropArea.classList.remove('highlight');
}

dropArea.addEventListener('drop', handleDrop, false);

function handleDrop(e) {
    const dt = e.dataTransfer;
    const files = dt.files;
    handleFiles(files);
}

dropArea.addEventListener('click', () => fileInput.click());
fileInput.addEventListener('change', () => handleFiles(fileInput.files));

function handleFiles(files) {
    if (files.length > 0) {
        const file = files[0];
        previewFile(file);
    }
}

function previewFile(file) {
    const reader = new FileReader();
    reader.readAsDataURL(file);
    reader.onloadend = function() {
        previewImage.src = reader.result;
        previewImage.style.display = 'block';
    }
}

detectButton.addEventListener('click', async () => {
    const apiKey = apiKeyInput.value;
    if (!apiKey) {
        alert('Please enter an API key');
        return;
    }

    if (!previewImage.src) {
        alert('Please select an image first');
        return;
    }

    const base64Image = previewImage.src.split(',')[1];
    resultDiv.textContent = 'Detecting objects...';

    try {
        const result = await backend.detectObjects(apiKey, base64Image);
        if (result.ok) {
            const detections = JSON.parse(result.ok);
            displayDetections(detections);
        } else {
            resultDiv.textContent = `Error: ${result.err}`;
        }
    } catch (error) {
        console.error('Error calling backend:', error);
        resultDiv.textContent = `Error: ${error.message}`;
    }
});

function displayDetections(detections) {
    resultDiv.innerHTML = '<h3>Detected Objects:</h3>';
    const ul = document.createElement('ul');
    detections.detections.forEach(detection => {
        const li = document.createElement('li');
        li.textContent = `${detection.element} (Confidence: ${(detection.confidence * 100).toFixed(2)}%)`;
        ul.appendChild(li);
    });
    resultDiv.appendChild(ul);
}
