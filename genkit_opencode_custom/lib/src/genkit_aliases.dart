// Copyright 2026 The genkit_opencode_custom authors.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import 'package:genkit/plugin.dart';

/// The raw `Action` instantiation of the `GenkitPlugin` contract.
///
/// `GenkitPlugin.init` and `resolve` are declared with raw `Action` types;
/// spelling the instantiation explicitly keeps `strict-raw-types` satisfied.
typedef AnyAction = Action<dynamic, dynamic, dynamic, dynamic>;

/// The raw `ActionMetadata` instantiation of the `GenkitPlugin` contract.
typedef AnyActionMetadata = ActionMetadata<dynamic, dynamic, dynamic, dynamic>;
