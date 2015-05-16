Package.describe({
  name: "maxnowack:fieldlevelsec",
  summary: "Meteor package that provides defining field-level security rules",
  version: "0.8.0",
  git: "https://github.com/maxnowack/meteor-fieldlevelsec"
});

Package.onUse(function(api) {
  api.versionsFrom("1.0.1");
  api.use(["coffeescript", "underscore"]);

  api.addFiles("server/fieldlevelsec.coffee", ["server"]);
  api.export('FieldLevelSec','server');
});


Package.onTest(function (api) {
  api.use("tinytest");
  api.use("coffeescript");
  api.use("maxnowack:fieldlevelsec");

  api.addFiles("tests/fieldlevelsec.coffee");

});
