project(
    'online-accounts',
    'vala', 'c',
    version: '2.0.1'
)

gettext_name = meson.project_name() + '-plug'
gnome = import('gnome')
i18n = import('i18n')

add_project_arguments(
    '-DGETTEXT_PACKAGE="@0@"'.format(gettext_name),
    language:'c'
)

glib_dep = dependency('glib-2.0')
gio_dep = dependency('gio-2.0')
gobject_dep = dependency('gobject-2.0')
libaccounts_dep = dependency('libaccounts-glib')
libsignon_glib = dependency('libsignon-glib')

json_glib_dep = dependency('json-glib-1.0')
rest_dep = dependency('rest-0.7')

hicolor_dir = join_paths(get_option('datadir'), 'icons', 'hicolor')

subdir('src')
subdir('data')
subdir('providers')
subdir('po')
