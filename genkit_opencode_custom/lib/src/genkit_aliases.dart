// Copyright 2026 The genkit_opencode_custom authors.
// SPDX-License-Identifier: MIT

import 'package:genkit/plugin.dart';

/// The raw `Action` instantiation of the `GenkitPlugin` contract.
///
/// `GenkitPlugin.init` and `resolve` are declared with raw `Action` types;
/// spelling the instantiation explicitly keeps `strict-raw-types` satisfied.
typedef AnyAction = Action<dynamic, dynamic, dynamic, dynamic>;

/// The raw `ActionMetadata` instantiation of the `GenkitPlugin` contract.
typedef AnyActionMetadata = ActionMetadata<dynamic, dynamic, dynamic, dynamic>;
