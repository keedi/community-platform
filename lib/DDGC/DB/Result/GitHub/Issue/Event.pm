package DDGC::DB::Result::GitHub::Issue::Event;
# ABSTRACT:

use Moose;
use MooseX::NonMoose;
extends 'DDGC::DB::Base::Result';
use DBIx::Class::Candy;
use namespace::autoclean;

table 'github_issue_event';

column id => {
  data_type => 'bigint',
  is_auto_increment => 1,
};
primary_key 'id';

unique_column github_id => {
  data_type => 'bigint',
  is_nullable => 0,
};

column github_user_id => {
  data_type => 'bigint',
  is_nullable => 0,
};
belongs_to 'github_user', 'DDGC::DB::Result::GitHub::User', 'github_user_id', {
  on_delete => 'cascade',
};

column event => {
  data_type => 'text',
  is_nullable => 0,
};

column github_issue_id => {
  data_type => 'bigint',
  is_nullable => 0,
};
belongs_to 'github_issue', 'DDGC::DB::Result::GitHub::Issue', 'github_issue_id', {
  on_delete => 'cascade',
};

column created_at => {
  data_type => 'timestamp without time zone',
  is_nullable => 0,
};

column created => {
  data_type => 'timestamp with time zone',
  set_on_create => 1,
};

column gh_data => {
  data_type => 'text',
  is_nullable => 0,
  serializer_class => 'AnyJSON',
  default_value => '{}',
};

no Moose;
__PACKAGE__->meta->make_immutable;
