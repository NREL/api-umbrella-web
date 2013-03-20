//= require jquery_ujs
//= require rails.validations
//= require vendor/jquery.slugify
//= require_self

$(document).ready(function() {
  $("textarea.editor").ckeditor({
    extraPlugins: "syntaxhighlight",
    height: 500,
    contentsCss: [
      "/assets/public.css",
      "/assets/ckeditor.css",
    ],
    stylesSet: [
      {
        name: "Section",
        element: "h2",
      },
      {
        name: "Sub-Section",
        element: "h3",
      },
      {
        name: "Service URL",
        element: "div",
        attributes: { "class" : "docs-service-url" }
      },
      {
        name: "Example URL",
        element: "div",
        attributes: { "class" : "docs-example-url" }
      }
    ],
    toolbar: [
      ["Styles"],
      ["Bold", "Italic", "-", "RemoveFormat"],
      ["Link", "Unlink"],
      ["NumberedList", "BulletedList", "-", "Outdent", "Indent"],
      ["Code", "Table", "Image"],
      ["Source"]
    ]
  });
});
