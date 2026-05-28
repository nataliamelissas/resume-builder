// Point PDF.js at the locally-hosted worker. Loaded after pdf.min.js so the
// `printing` package finds `window.pdfjsLib` already initialized and skips
// its own dynamic CDN fetch.
window.pdfjsLib.GlobalWorkerOptions.workerSrc = 'pdfjs/pdf.worker-3.2.146.min.js';
