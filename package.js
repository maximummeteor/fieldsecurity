Package.describe({
  name: "maximum:fieldsecurity",
  summary: "Meteor package that provides defining field-level security rules",
  version: "0.8.1",
  git: "https://github.com/maximummeteor/fieldsecurity"
});

Package.onUse(function(api) {
  api.versionsFrom("1.0.1");
  api.use(["coffeescript", "underscore"]);

  api.addFiles("server/fieldsecurity.coffee", ["server"]);
  api.export('FieldSecurity','server');
});


Package.onTest(function (api) {
  api.use("tinytest");
  api.use("coffeescript");
  api.use("maximum:fieldsecurity");

  api.addFiles("tests/fieldsecurity.coffee");

});
