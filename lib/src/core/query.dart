/// Query parameter helpers shared by generated resources.
library;

import 'json_utils.dart';
import 'request_options.dart';

/// Builds the `location[directory]` query entry for an operation.
///
/// An explicit [location] takes precedence over `options.location`. A
/// directory-less location follows the server default and adds no entry.
JsonMap locationQuery(LocationRef? location, RequestOptions? options) {
  final directory = (location ?? options?.location)?.directory;
  return <String, Object?>{
    if (directory != null) 'location[directory]': directory,
  };
}
