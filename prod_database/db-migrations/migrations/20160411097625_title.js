
exports.up = function(knex) {
  return knex.schema.createTable('posts', function (table) {
    table.increments();
    table.string('title');
  });
};

exports.down = function(knex) {
  return knex.schema.dropTable('posts');
};
