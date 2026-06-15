// ignore: avoid_web_libraries_in_flutter
import 'dart:js' as js;

void printLabelImpl({required String productName, required String barcodeValue, String? price}) {
  final escapedName = productName
      .replaceAll('&', '&amp;')
      .replaceAll('<', '&lt;')
      .replaceAll('>', '&gt;')
      .replaceAll('"', '&quot;');

  final escapedBarcode = barcodeValue.replaceAll('"', '&quot;');
  final escapedPrice = (price ?? '').replaceAll('&', '&amp;').replaceAll('<', '&lt;');

  final bool hasPrice = price != null && price.trim().isNotEmpty;

  final int nameLen = productName.length;
  final String nameFontSize = nameLen > 28 ? '9px' : nameLen > 20 ? '10px' : '11.5px';

  // Price row — only rendered when a price is provided
  final String priceHtml = hasPrice
      ? '<div class="price">\$${escapedPrice}</div>'
      : '';

  // Shrink barcode height slightly when price is shown to keep everything fitting
  final int barcodeHeight = hasPrice ? 40 : 52;

  final content = '''<!DOCTYPE html><html><head><title>Label</title>
<script src="https://cdn.jsdelivr.net/npm/jsbarcode@3.11.6/dist/JsBarcode.all.min.js"><\/script>
<style>
  * { box-sizing:border-box; margin:0; padding:0; }
  body { background:#f5f5f5; display:flex; flex-wrap:wrap; gap:10px; padding:16px; }
  .label { width:252px; height:144px; border:1px solid #222; border-radius:3px; display:flex; background:#fff; font-family:Arial,sans-serif; overflow:hidden; page-break-inside:avoid; }
  .stripe { width:26px; border-right:1px solid #222; display:flex; align-items:center; justify-content:center; writing-mode:vertical-rl; text-orientation:mixed; transform:rotate(180deg); font-size:11px; font-weight:900; letter-spacing:2px; color:#111; white-space:nowrap; }
  .body { flex:1; display:flex; flex-direction:column; align-items:center; justify-content:center; padding:6px 8px 4px; gap:3px; }
  .pname { font-size:$nameFontSize; font-weight:700; color:#111; text-align:center; line-height:1.2; }
  .price { font-size:20px; font-weight:900; color:#111; letter-spacing:-0.5px; line-height:1; }
  .bc { max-width:100%; }
  .mpr { font-size:9px; color:#0070c0; font-weight:600; letter-spacing:.5px; margin-top:-2px; }
  @media print { body { background:white; padding:4px; } .label { break-inside:avoid; } }
</style></head><body>
<div class="label">
  <div class="stripe">MANDEL</div>
  <div class="body">
    <div class="pname">$escapedName</div>
    $priceHtml
    <svg class="bc" data-value="$escapedBarcode" data-height="$barcodeHeight"></svg>
    <div class="mpr">$escapedBarcode</div>
  </div>
</div>
<script>
  window.addEventListener('load', function() {
    document.querySelectorAll('.bc').forEach(function(el) {
      var h = parseInt(el.getAttribute('data-height') || '52', 10);
      JsBarcode(el, el.getAttribute('data-value'), { format:'CODE128', width:2, height:h, displayValue:false, margin:0 });
    });
    setTimeout(function(){ window.print(); }, 400);
  });
<\/script></body></html>''';

  final win = js.context.callMethod('open', ['', '_blank', 'width=400,height=300']);
  if (win != null) {
    final doc = win['document'] as js.JsObject;
    doc.callMethod('write', [content]);
    doc.callMethod('close', []);
  }
}
