// Point PDF.js at the locally-hosted worker. The filename must stay
// `pdf.worker.min.js` — PDF.js v3 auto-derives the worker URL as a sibling
// of the loaded library with that exact basename. Versioning the worker
// breaks that lookup; the main library is still version-pinned for cache-
// busting.
window.pdfjsLib.GlobalWorkerOptions.workerSrc = 'pdfjs/pdf.worker.min.js';
