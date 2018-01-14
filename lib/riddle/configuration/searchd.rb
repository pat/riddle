# frozen_string_literal: true

module Riddle
  class Configuration
    class Searchd < Riddle::Configuration::Section
      def self.settings
        [
          :listen, :address, :port, :log, :query_log,
          :query_log_format, :read_timeout, :client_timeout, :max_children,
          :pid_file, :max_matches, :seamless_rotate, :preopen_indexes,
          :unlink_old, :attr_flush_period, :ondisk_dict_default,
          :max_packet_size, :mva_updates_pool, :crash_log_path, :max_filters,
          :max_filter_values, :listen_backlog, :read_buffer, :read_unhinted,
          :max_batch_queries, :subtree_docs_cache, :subtree_hits_cache,
          :workers, :dist_threads, :binlog_path, :binlog_flush,
          :binlog_max_log_size, :snippets_file_prefix, :collation_server,
          :collation_libc_locale, :mysql_version_string,
          :rt_flush_period, :thread_stack, :expansion_limit,
          :compat_sphinxql_magics, :watchdog, :prefork_rotation_throttle,
          :sphinxql_state, :ha_ping_interval, :ha_period_karma,
          :persistent_connections_limit, :rt_merge_iops, :rt_merge_maxiosize,
          :predicted_time_costs, :snippets_file_prefix, :shutdown_timeout,
          :ondisk_attrs_default, :query_log_min_msec, :agent_connect_timeout,
          :agent_query_timeout, :agent_retry_count, :agenty_retry_delay,
          :client_key
        ]
      end

      attr_accessor *self.settings
      attr_accessor :mysql41, :socket

      def render
        raise ConfigurationError unless valid?

        (
          ["searchd", "{"] +
          settings_body +
          ["}", ""]
        ).join("\n")
      end

      def valid?
        !( @port.nil? || @pid_file.nil? )
      end
    end
  end
end
