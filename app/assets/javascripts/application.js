// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// the compiled file.
//
// WARNING: THE FIRST BLANK LINE MARKS THE END OF WHAT'S TO BE PROCESSED, ANY BLANK LINE SHOULD
// GO AFTER THE REQUIRES BELOW.
//
//= require jquery
//= require jquery-ui
//= require jquery_ujs
//= require_tree .

function calcFrameHeight(id) {
  iframe = document.getElementById(id);
  try
  {
    var innerDoc = (iframe.contentDocument) ? iframe.contentDocument : iframe.contentWindow.document;
    if (innerDoc.body.offsetHeight) { //ns6 syntax 
      iframe.height = innerDoc.body.offsetHeight + 32; //Extra height FireFox
    } else if (iframe.Document && iframe.Document.body.scrollHeight) { //ie5+ syntax
      iframe.height = iframe.Document.body.scrollHeight;
    }
  } catch(err) {
    alert(err.message);
  }
}
