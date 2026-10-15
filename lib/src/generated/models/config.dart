// GENERATED CODE - DO NOT MODIFY BY HAND
part of '../models.dart';
// ignore_for_file: prefer_if_null_operators, unnecessary_lambdas, use_super_parameters

/// `Config.AgentEncoded`
final class ConfigAgentEncoded {
  const ConfigAgentEncoded({
    this.model,
    this.request,
    this.system,
    this.description,
    this.mode,
    this.hidden,
    this.color,
    this.steps,
    this.disabled,
    this.permissions,
  });

  factory ConfigAgentEncoded.fromJson(Map<String, Object?> json) =>
      ConfigAgentEncoded(
        model: json['model'],
        request: json['request'] == null
            ? null
            : ConfigAgentEncodedRequest.fromJson(asJsonMap(json['request'])),
        system: decodeOptionalString(json, 'system'),
        description: decodeOptionalString(json, 'description'),
        mode: json['mode'] == null
            ? null
            : ConfigAgentEncodedMode.fromJson(json['mode']),
        hidden: decodeOptionalBool(json, 'hidden'),
        color: decodeOptionalString(json, 'color'),
        steps: decodeOptionalInt(json, 'steps'),
        disabled: decodeOptionalBool(json, 'disabled'),
        permissions: json['permissions'] == null
            ? null
            : jsonList(json['permissions'],
                (item) => PermissionRule.fromJson(asJsonMap(item))),
      );

  final Object? model;
  final ConfigAgentEncodedRequest? request;
  final String? system;
  final String? description;
  final ConfigAgentEncodedMode? mode;
  final bool? hidden;
  final String? color;
  final int? steps;
  final bool? disabled;
  final List<PermissionRule>? permissions;

  Map<String, Object?> toJson() => <String, Object?>{
        if (model != null) 'model': model!,
        if (request != null) 'request': request!.toJson(),
        if (system != null) 'system': system!,
        if (description != null) 'description': description!,
        if (mode != null) 'mode': mode!.wire,
        if (hidden != null) 'hidden': hidden!,
        if (color != null) 'color': color!,
        if (steps != null) 'steps': steps!,
        if (disabled != null) 'disabled': disabled!,
        if (permissions != null)
          'permissions': [for (final item in permissions!) item.toJson()],
      };
}

/// `Config.CommandEncoded`
final class ConfigCommandEncoded {
  const ConfigCommandEncoded({
    required this.template,
    this.description,
    this.agent,
    this.model,
    this.subagent,
    this.subtask,
  });

  factory ConfigCommandEncoded.fromJson(Map<String, Object?> json) =>
      ConfigCommandEncoded(
        template: decodeString(json, 'template'),
        description: decodeOptionalString(json, 'description'),
        agent: decodeOptionalString(json, 'agent'),
        model: json['model'],
        subagent: decodeOptionalBool(json, 'subagent'),
        subtask: decodeOptionalBool(json, 'subtask'),
      );

  final String template;
  final String? description;
  final String? agent;
  final Object? model;
  final bool? subagent;
  final bool? subtask;

  Map<String, Object?> toJson() => <String, Object?>{
        'template': template,
        if (description != null) 'description': description!,
        if (agent != null) 'agent': agent!,
        if (model != null) 'model': model!,
        if (subagent != null) 'subagent': subagent!,
        if (subtask != null) 'subtask': subtask!,
      };
}

/// `Config.DirectoryEncoded`
final class ConfigDirectoryEncoded extends ConfigEntry {
  const ConfigDirectoryEncoded({
    required this.path,
  });

  factory ConfigDirectoryEncoded.fromJson(Map<String, Object?> json) =>
      ConfigDirectoryEncoded(
        path: AbsolutePath.fromJson(asJsonString(json['path'])),
      );

  final AbsolutePath path;

  /// Always `directory`.
  @override
  String get type => 'directory';

  @override
  Map<String, Object?> toJson() => <String, Object?>{
        'type': 'directory',
        'path': path,
      };
}

/// `Config.DocumentEncoded`
final class ConfigDocumentEncoded extends ConfigEntry {
  const ConfigDocumentEncoded({
    this.path,
    required this.info,
  });

  factory ConfigDocumentEncoded.fromJson(Map<String, Object?> json) =>
      ConfigDocumentEncoded(
        path: json['path'] == null
            ? null
            : AbsolutePath.fromJson(asJsonString(json['path'])),
        info: ConfigInfoEncoded.fromJson(asJsonMap(json['info'])),
      );

  final AbsolutePath? path;
  final ConfigInfoEncoded info;

  /// Always `document`.
  @override
  String get type => 'document';

  @override
  Map<String, Object?> toJson() => <String, Object?>{
        'type': 'document',
        if (path != null) 'path': path!,
        'info': info.toJson(),
      };
}

/// `Config.InfoEncoded`
final class ConfigInfoEncoded {
  const ConfigInfoEncoded({
    this.schema,
    this.shell,
    this.model,
    this.defaultAgent,
    this.update,
    this.share,
    this.enterprise,
    this.username,
    this.permissions,
    this.policies,
    this.agents,
    this.snapshots,
    this.watcher,
    this.formatter,
    this.lsp,
    this.media,
    this.toolOutput,
    this.mcp,
    this.compaction,
    this.skills,
    this.commands,
    this.instructions,
    this.references,
    this.websearch,
    this.plugins,
    this.worktree,
    this.warming,
    this.providers,
    this.experimental,
  });

  factory ConfigInfoEncoded.fromJson(Map<String, Object?> json) =>
      ConfigInfoEncoded(
        schema: decodeOptionalString(json, '\$schema'),
        shell: decodeOptionalString(json, 'shell'),
        model: json['model'],
        defaultAgent: decodeOptionalString(json, 'default_agent'),
        update: json['update'] == null
            ? null
            : ConfigInfoEncodedUpdate.fromJson(json['update']),
        share: json['share'] == null
            ? null
            : ConfigInfoEncodedShare.fromJson(json['share']),
        enterprise: json['enterprise'] == null
            ? null
            : ConfigInfoEncodedEnterprise.fromJson(
                asJsonMap(json['enterprise'])),
        username: decodeOptionalString(json, 'username'),
        permissions: json['permissions'] == null
            ? null
            : jsonList(json['permissions'],
                (item) => PermissionRule.fromJson(asJsonMap(item))),
        policies: json['policies'] == null
            ? null
            : jsonList(json['policies'],
                (item) => ConfigInfoEncodedPolicies.fromJson(asJsonMap(item))),
        agents: json['agents'] == null ? null : asJsonMap(json['agents']),
        snapshots: decodeOptionalBool(json, 'snapshots'),
        watcher: json['watcher'] == null
            ? null
            : ConfigInfoEncodedWatcher.fromJson(asJsonMap(json['watcher'])),
        formatter: json['formatter'],
        lsp: json['lsp'],
        media: json['media'] == null
            ? null
            : ConfigInfoEncodedMedia.fromJson(asJsonMap(json['media'])),
        toolOutput: json['tool_output'] == null
            ? null
            : ConfigInfoEncodedToolOutput.fromJson(
                asJsonMap(json['tool_output'])),
        mcp: json['mcp'] == null
            ? null
            : ConfigInfoEncodedMcp.fromJson(asJsonMap(json['mcp'])),
        compaction: json['compaction'] == null
            ? null
            : ConfigInfoEncodedCompaction.fromJson(
                asJsonMap(json['compaction'])),
        skills: json['skills'] == null
            ? null
            : jsonList(json['skills'], (item) => asJsonString(item)),
        commands: json['commands'] == null ? null : asJsonMap(json['commands']),
        instructions: json['instructions'] == null
            ? null
            : jsonList(json['instructions'], (item) => asJsonString(item)),
        references:
            json['references'] == null ? null : asJsonMap(json['references']),
        websearch: json['websearch'],
        plugins: json['plugins'] == null
            ? null
            : jsonList(json['plugins'], (item) => item),
        worktree: json['worktree'] == null
            ? null
            : ConfigWorktree.fromJson(asJsonMap(json['worktree'])),
        warming: json['warming'],
        providers:
            json['providers'] == null ? null : asJsonMap(json['providers']),
        experimental: json['experimental'] == null
            ? null
            : ConfigInfoEncodedExperimental.fromJson(
                asJsonMap(json['experimental'])),
      );

  /// Wire field: `$schema`.
  final String? schema;
  final String? shell;
  final Object? model;

  /// Wire field: `default_agent`.
  final String? defaultAgent;
  final ConfigInfoEncodedUpdate? update;
  final ConfigInfoEncodedShare? share;
  final ConfigInfoEncodedEnterprise? enterprise;
  final String? username;
  final List<PermissionRule>? permissions;
  final List<ConfigInfoEncodedPolicies>? policies;
  final Map<String, Object?>? agents;
  final bool? snapshots;
  final ConfigInfoEncodedWatcher? watcher;
  final Object? formatter;
  final Object? lsp;
  final ConfigInfoEncodedMedia? media;

  /// Wire field: `tool_output`.
  final ConfigInfoEncodedToolOutput? toolOutput;
  final ConfigInfoEncodedMcp? mcp;
  final ConfigInfoEncodedCompaction? compaction;
  final List<String>? skills;
  final Map<String, Object?>? commands;
  final List<String>? instructions;
  final Map<String, Object?>? references;
  final Object? websearch;
  final List<Object?>? plugins;
  final ConfigWorktree? worktree;
  final Object? warming;
  final Map<String, Object?>? providers;
  final ConfigInfoEncodedExperimental? experimental;

  Map<String, Object?> toJson() => <String, Object?>{
        if (schema != null) '\$schema': schema!,
        if (shell != null) 'shell': shell!,
        if (model != null) 'model': model!,
        if (defaultAgent != null) 'default_agent': defaultAgent!,
        if (update != null) 'update': update!.wire,
        if (share != null) 'share': share!.wire,
        if (enterprise != null) 'enterprise': enterprise!.toJson(),
        if (username != null) 'username': username!,
        if (permissions != null)
          'permissions': [for (final item in permissions!) item.toJson()],
        if (policies != null)
          'policies': [for (final item in policies!) item.toJson()],
        if (agents != null) 'agents': agents!,
        if (snapshots != null) 'snapshots': snapshots!,
        if (watcher != null) 'watcher': watcher!.toJson(),
        if (formatter != null) 'formatter': formatter!,
        if (lsp != null) 'lsp': lsp!,
        if (media != null) 'media': media!.toJson(),
        if (toolOutput != null) 'tool_output': toolOutput!.toJson(),
        if (mcp != null) 'mcp': mcp!.toJson(),
        if (compaction != null) 'compaction': compaction!.toJson(),
        if (skills != null) 'skills': skills!,
        if (commands != null) 'commands': commands!,
        if (instructions != null) 'instructions': instructions!,
        if (references != null) 'references': references!,
        if (websearch != null) 'websearch': websearch!,
        if (plugins != null) 'plugins': plugins!,
        if (worktree != null) 'worktree': worktree!.toJson(),
        if (warming != null) 'warming': warming!,
        if (providers != null) 'providers': providers!,
        if (experimental != null) 'experimental': experimental!.toJson(),
      };
}

/// `Config.Worktree`
final class ConfigWorktree {
  const ConfigWorktree({
    required this.directory,
  });

  factory ConfigWorktree.fromJson(Map<String, Object?> json) => ConfigWorktree(
        directory: decodeString(json, 'directory'),
      );

  final String directory;

  Map<String, Object?> toJson() => <String, Object?>{
        'directory': directory,
      };
}

/// `Config.Entry`
sealed class ConfigEntry {
  const ConfigEntry();

  /// Decodes a payload into the matching variant.
  factory ConfigEntry.fromJson(Map<String, Object?> json) {
    final value = json['type'];
    return switch (value) {
      'document' => ConfigDocumentEncoded.fromJson(json),
      'directory' => ConfigDirectoryEncoded.fromJson(json),
      _ => throw OpenCodeDecodeException(
          'Unknown Config.Entry discriminator: $value'),
    };
  }

  /// Present on every variant (`type`).
  String get type;

  /// Encodes this value to JSON.
  Map<String, Object?> toJson();
}

/// `Config.Formatter.EntryEncoded`
final class ConfigFormatterEntryEncoded {
  const ConfigFormatterEntryEncoded({
    this.disabled,
    this.command,
    this.environment,
    this.extensions,
  });

  factory ConfigFormatterEntryEncoded.fromJson(Map<String, Object?> json) =>
      ConfigFormatterEntryEncoded(
        disabled: decodeOptionalBool(json, 'disabled'),
        command: json['command'] == null
            ? null
            : jsonList(json['command'], (item) => asJsonString(item)),
        environment:
            json['environment'] == null ? null : asJsonMap(json['environment']),
        extensions: json['extensions'] == null
            ? null
            : jsonList(json['extensions'], (item) => asJsonString(item)),
      );

  final bool? disabled;
  final List<String>? command;
  final Map<String, Object?>? environment;
  final List<String>? extensions;

  Map<String, Object?> toJson() => <String, Object?>{
        if (disabled != null) 'disabled': disabled!,
        if (command != null) 'command': command!,
        if (environment != null) 'environment': environment!,
        if (extensions != null) 'extensions': extensions!,
      };
}

/// `Config.LSP.ServerEncoded`
final class ConfigLSPServerEncoded {
  const ConfigLSPServerEncoded({
    required this.command,
    this.extensions,
    this.disabled,
    this.env,
    this.initialization,
  });

  factory ConfigLSPServerEncoded.fromJson(Map<String, Object?> json) =>
      ConfigLSPServerEncoded(
        command: jsonList(json['command'], (item) => asJsonString(item)),
        extensions: json['extensions'] == null
            ? null
            : jsonList(json['extensions'], (item) => asJsonString(item)),
        disabled: decodeOptionalBool(json, 'disabled'),
        env: json['env'] == null ? null : asJsonMap(json['env']),
        initialization: json['initialization'] == null
            ? null
            : asJsonMap(json['initialization']),
      );

  final List<String> command;
  final List<String>? extensions;
  final bool? disabled;
  final Map<String, Object?>? env;
  final Map<String, Object?>? initialization;

  Map<String, Object?> toJson() => <String, Object?>{
        'command': command,
        if (extensions != null) 'extensions': extensions!,
        if (disabled != null) 'disabled': disabled!,
        if (env != null) 'env': env!,
        if (initialization != null) 'initialization': initialization!,
      };
}

/// `Config.Model.Capabilities`
final class ConfigModelCapabilities {
  const ConfigModelCapabilities({
    this.tools,
    this.input,
    this.output,
  });

  factory ConfigModelCapabilities.fromJson(Map<String, Object?> json) =>
      ConfigModelCapabilities(
        tools: decodeOptionalBool(json, 'tools'),
        input: json['input'] == null
            ? null
            : jsonList(json['input'], (item) => asJsonString(item)),
        output: json['output'] == null
            ? null
            : jsonList(json['output'], (item) => asJsonString(item)),
      );

  final bool? tools;
  final List<String>? input;
  final List<String>? output;

  Map<String, Object?> toJson() => <String, Object?>{
        if (tools != null) 'tools': tools!,
        if (input != null) 'input': input!,
        if (output != null) 'output': output!,
      };
}

/// `Config.Model.CostEncoded`
final class ConfigModelCostEncoded {
  const ConfigModelCostEncoded({
    this.tier,
    required this.input,
    required this.output,
    this.cache,
  });

  factory ConfigModelCostEncoded.fromJson(Map<String, Object?> json) =>
      ConfigModelCostEncoded(
        tier: json['tier'] == null
            ? null
            : ConfigModelCostEncodedTier.fromJson(asJsonMap(json['tier'])),
        input: MoneyUSDPerMillionTokens.fromJson(asJsonDouble(json['input'])),
        output: MoneyUSDPerMillionTokens.fromJson(asJsonDouble(json['output'])),
        cache: json['cache'] == null
            ? null
            : ConfigModelCostEncodedCache.fromJson(asJsonMap(json['cache'])),
      );

  final ConfigModelCostEncodedTier? tier;
  final MoneyUSDPerMillionTokens input;
  final MoneyUSDPerMillionTokens output;
  final ConfigModelCostEncodedCache? cache;

  Map<String, Object?> toJson() => <String, Object?>{
        if (tier != null) 'tier': tier!.toJson(),
        'input': input,
        'output': output,
        if (cache != null) 'cache': cache!.toJson(),
      };
}

/// `Config.Model.Settings`
final class ConfigModelSettings {
  const ConfigModelSettings({
    this.compaction,
    this.encoding,
  });

  factory ConfigModelSettings.fromJson(Map<String, Object?> json) =>
      ConfigModelSettings(
        compaction: json['compaction'] == null
            ? null
            : ProviderCompaction.fromJson(asJsonMap(json['compaction'])),
        encoding: json['encoding'] == null
            ? null
            : ProviderEncoding.fromJson(json['encoding']),
      );

  final ProviderCompaction? compaction;
  final ProviderEncoding? encoding;

  Map<String, Object?> toJson() => <String, Object?>{
        if (compaction != null) 'compaction': compaction!.toJson(),
        if (encoding != null) 'encoding': encoding!.wire,
      };
}

/// `Config.ModelEncoded`
final class ConfigModelEncoded {
  const ConfigModelEncoded({
    this.modelID,
    this.family,
    this.name,
    this.compatibility,
    this.package,
    this.settings,
    this.headers,
    this.body,
    this.capabilities,
    this.variants,
    this.cost,
    this.disabled,
    this.limit,
  });

  factory ConfigModelEncoded.fromJson(Map<String, Object?> json) =>
      ConfigModelEncoded(
        modelID: decodeOptionalString(json, 'modelID'),
        family: decodeOptionalString(json, 'family'),
        name: decodeOptionalString(json, 'name'),
        compatibility: json['compatibility'] == null
            ? null
            : ModelCompatibility.fromJson(asJsonMap(json['compatibility'])),
        package: decodeOptionalString(json, 'package'),
        settings: json['settings'] == null
            ? null
            : ConfigModelSettings.fromJson(asJsonMap(json['settings'])),
        headers: json['headers'] == null ? null : asJsonMap(json['headers']),
        body: json['body'] == null ? null : asJsonMap(json['body']),
        capabilities: json['capabilities'] == null
            ? null
            : ConfigModelCapabilities.fromJson(asJsonMap(json['capabilities'])),
        variants: json['variants'] == null
            ? null
            : jsonList(json['variants'],
                (item) => ConfigModelEncodedVariants.fromJson(asJsonMap(item))),
        cost: json['cost'],
        disabled: decodeOptionalBool(json, 'disabled'),
        limit: json['limit'] == null
            ? null
            : ConfigModelEncodedLimit.fromJson(asJsonMap(json['limit'])),
      );

  final String? modelID;
  final String? family;
  final String? name;
  final ModelCompatibility? compatibility;
  final String? package;
  final ConfigModelSettings? settings;
  final Map<String, Object?>? headers;
  final Map<String, Object?>? body;
  final ConfigModelCapabilities? capabilities;
  final List<ConfigModelEncodedVariants>? variants;
  final Object? cost;
  final bool? disabled;
  final ConfigModelEncodedLimit? limit;

  Map<String, Object?> toJson() => <String, Object?>{
        if (modelID != null) 'modelID': modelID!,
        if (family != null) 'family': family!,
        if (name != null) 'name': name!,
        if (compatibility != null) 'compatibility': compatibility!.toJson(),
        if (package != null) 'package': package!,
        if (settings != null) 'settings': settings!.toJson(),
        if (headers != null) 'headers': headers!,
        if (body != null) 'body': body!,
        if (capabilities != null) 'capabilities': capabilities!.toJson(),
        if (variants != null)
          'variants': [for (final item in variants!) item.toJson()],
        if (cost != null) 'cost': cost!,
        if (disabled != null) 'disabled': disabled!,
        if (limit != null) 'limit': limit!.toJson(),
      };
}

/// `Config.Patch`
final class ConfigPatch {
  const ConfigPatch({
    required this.shell,
  });

  factory ConfigPatch.fromJson(Map<String, Object?> json) => ConfigPatch(
        shell: decodeOptionalString(json, 'shell'),
      );

  final String? shell;

  Map<String, Object?> toJson() => <String, Object?>{
        if (shell != null) 'shell': shell!,
      };
}

/// `Config.Plugin.EntryEncoded`
final class ConfigPluginEntryEncoded {
  const ConfigPluginEntryEncoded({
    required this.package,
    this.options,
  });

  factory ConfigPluginEntryEncoded.fromJson(Map<String, Object?> json) =>
      ConfigPluginEntryEncoded(
        package: decodeString(json, 'package'),
        options: json['options'] == null ? null : asJsonMap(json['options']),
      );

  final String package;
  final Map<String, Object?>? options;

  Map<String, Object?> toJson() => <String, Object?>{
        'package': package,
        if (options != null) 'options': options!,
      };
}

/// `Config.Provider.Settings`
final class ConfigProviderSettings {
  const ConfigProviderSettings({
    this.timeout,
    this.headerTimeout,
    this.chunkTimeout,
    this.compaction,
    this.transport,
    this.encoding,
  });

  factory ConfigProviderSettings.fromJson(Map<String, Object?> json) =>
      ConfigProviderSettings(
        timeout: json['timeout'],
        headerTimeout: json['headerTimeout'],
        chunkTimeout: json['chunkTimeout'],
        compaction: json['compaction'] == null
            ? null
            : ProviderCompaction.fromJson(asJsonMap(json['compaction'])),
        transport: json['transport'] == null
            ? null
            : ProviderTransport.fromJson(json['transport']),
        encoding: json['encoding'] == null
            ? null
            : ProviderEncoding.fromJson(json['encoding']),
      );

  final Object? timeout;
  final Object? headerTimeout;
  final Object? chunkTimeout;
  final ProviderCompaction? compaction;
  final ProviderTransport? transport;
  final ProviderEncoding? encoding;

  Map<String, Object?> toJson() => <String, Object?>{
        if (timeout != null) 'timeout': timeout!,
        if (headerTimeout != null) 'headerTimeout': headerTimeout!,
        if (chunkTimeout != null) 'chunkTimeout': chunkTimeout!,
        if (compaction != null) 'compaction': compaction!.toJson(),
        if (transport != null) 'transport': transport!.wire,
        if (encoding != null) 'encoding': encoding!.wire,
      };
}

/// `Config.ProviderEncoded`
final class ConfigProviderEncoded {
  const ConfigProviderEncoded({
    this.canonical,
    this.name,
    this.env,
    this.package,
    this.compatibility,
    this.settings,
    this.headers,
    this.body,
    this.models,
  });

  factory ConfigProviderEncoded.fromJson(Map<String, Object?> json) =>
      ConfigProviderEncoded(
        canonical: json['canonical'] == null
            ? null
            : ProviderID.fromJson(asJsonString(json['canonical'])),
        name: decodeOptionalString(json, 'name'),
        env: json['env'] == null
            ? null
            : jsonList(json['env'], (item) => asJsonString(item)),
        package: decodeOptionalString(json, 'package'),
        compatibility: json['compatibility'] == null
            ? null
            : ProviderCompatibility.fromJson(asJsonMap(json['compatibility'])),
        settings: json['settings'] == null
            ? null
            : ConfigProviderSettings.fromJson(asJsonMap(json['settings'])),
        headers: json['headers'] == null ? null : asJsonMap(json['headers']),
        body: json['body'] == null ? null : asJsonMap(json['body']),
        models: json['models'] == null ? null : asJsonMap(json['models']),
      );

  final ProviderID? canonical;
  final String? name;
  final List<String>? env;
  final String? package;
  final ProviderCompatibility? compatibility;
  final ConfigProviderSettings? settings;
  final Map<String, Object?>? headers;
  final Map<String, Object?>? body;
  final Map<String, Object?>? models;

  Map<String, Object?> toJson() => <String, Object?>{
        if (canonical != null) 'canonical': canonical!,
        if (name != null) 'name': name!,
        if (env != null) 'env': env!,
        if (package != null) 'package': package!,
        if (compatibility != null) 'compatibility': compatibility!.toJson(),
        if (settings != null) 'settings': settings!.toJson(),
        if (headers != null) 'headers': headers!,
        if (body != null) 'body': body!,
        if (models != null) 'models': models!,
      };
}

/// `Config.Reference.GitEncoded`
final class ConfigReferenceGitEncoded {
  const ConfigReferenceGitEncoded({
    required this.repository,
    this.branch,
    this.description,
    this.hidden,
  });

  factory ConfigReferenceGitEncoded.fromJson(Map<String, Object?> json) =>
      ConfigReferenceGitEncoded(
        repository: decodeString(json, 'repository'),
        branch: decodeOptionalString(json, 'branch'),
        description: decodeOptionalString(json, 'description'),
        hidden: decodeOptionalBool(json, 'hidden'),
      );

  final String repository;
  final String? branch;
  final String? description;
  final bool? hidden;

  Map<String, Object?> toJson() => <String, Object?>{
        'repository': repository,
        if (branch != null) 'branch': branch!,
        if (description != null) 'description': description!,
        if (hidden != null) 'hidden': hidden!,
      };
}

/// `Config.Reference.LocalEncoded`
final class ConfigReferenceLocalEncoded {
  const ConfigReferenceLocalEncoded({
    required this.path,
    this.description,
    this.hidden,
  });

  factory ConfigReferenceLocalEncoded.fromJson(Map<String, Object?> json) =>
      ConfigReferenceLocalEncoded(
        path: decodeString(json, 'path'),
        description: decodeOptionalString(json, 'description'),
        hidden: decodeOptionalBool(json, 'hidden'),
      );

  final String path;
  final String? description;
  final bool? hidden;

  Map<String, Object?> toJson() => <String, Object?>{
        'path': path,
        if (description != null) 'description': description!,
        if (hidden != null) 'hidden': hidden!,
      };
}

/// `Config.WarmingEncoded`
final class ConfigWarmingEncoded {
  const ConfigWarmingEncoded({
    this.prompt,
    this.interval,
    this.duration,
  });

  factory ConfigWarmingEncoded.fromJson(Map<String, Object?> json) =>
      ConfigWarmingEncoded(
        prompt: decodeOptionalString(json, 'prompt'),
        interval: decodeOptionalString(json, 'interval'),
        duration: decodeOptionalString(json, 'duration'),
      );

  final String? prompt;
  final String? interval;
  final String? duration;

  Map<String, Object?> toJson() => <String, Object?>{
        if (prompt != null) 'prompt': prompt!,
        if (interval != null) 'interval': interval!,
        if (duration != null) 'duration': duration!,
      };
}

/// `ConfigShell.Option`
final class ConfigShellOption {
  const ConfigShellOption({
    required this.path,
    required this.name,
    required this.acceptable,
  });

  factory ConfigShellOption.fromJson(Map<String, Object?> json) =>
      ConfigShellOption(
        path: decodeString(json, 'path'),
        name: decodeString(json, 'name'),
        acceptable: decodeBool(json, 'acceptable'),
      );

  final String path;
  final String name;
  final bool acceptable;

  Map<String, Object?> toJson() => <String, Object?>{
        'path': path,
        'name': name,
        'acceptable': acceptable,
      };
}

/// `ConfigWebSearch.InfoEncoded`
final class ConfigWebSearchInfoEncoded {
  const ConfigWebSearchInfoEncoded({
    required this.provider,
  });

  factory ConfigWebSearchInfoEncoded.fromJson(Map<String, Object?> json) =>
      ConfigWebSearchInfoEncoded(
        provider: json['provider'],
      );

  final Object? provider;

  Map<String, Object?> toJson() => <String, Object?>{
        'provider': provider,
      };
}
