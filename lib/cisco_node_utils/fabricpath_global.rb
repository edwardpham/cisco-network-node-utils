#
# NXAPI implementation of Fabricpath Global class
#
# November 2015, Deepak Cherian
#
# Copyright (c) 2015 Cisco and/or its affiliates.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

require_relative 'node_util'

module Cisco
  # node_utils class for fabricpath_global
  class FabricpathGlobal < NodeUtil
    attr_reader :name

    def initialize(name, instantiate=true)
      fail TypeError unless name.is_a?(String)
      fail ArgumentError unless name == 'default'
      @name = name.downcase
      @set_params = {}

      create if instantiate
    end

    def self.globals
      hash = {}
      is_fabricpath_feature = config_get('fabricpath', 'feature')
      return hash if (:enabled != is_fabricpath_feature.to_sym)
      hash['default'] = FabricpathGlobal.new('default', false)
      hash
    end

    def self.fabricpath_feature
      fabricpath = config_get('fabricpath', 'feature')
      fail 'fabricpath_feature not found' if fabricpath.nil?
      return :disabled if fabricpath.nil?
      fabricpath.to_sym
    end

    def self.fabricpath_feature_set(fabricpath_set)
      curr = FabricpathGlobal.fabricpath_feature
      return if curr == fabricpath_set

      case fabricpath_set
      when :enabled
        config_set('fabricpath', 'feature_install',
                   state: '') if curr == :uninstalled
        config_set('fabricpath', 'feature', state: '')
      when :disabled
        config_set('fabricpath', 'feature', state: 'no') if curr == :enabled
        return
      when :installed
        config_set('fabricpath', 'feature_install',
                   state: '') if curr == :uninstalled
      when :uninstalled
        config_set('fabricpath', 'feature', state: 'no') if curr == :enabled
        config_set('fabricpath', 'feature_install', state: 'no')
      end
    rescue Cisco::CliError => e
      raise "[#{@name}] '#{e.command}' : #{e.clierror}"
    end

    def create
      FabricpathGlobal.fabricpath_feature_set(:enabled) unless
      :enabled == FabricpathGlobal.fabricpath_feature
    end

    def destroy
      @name = nil
      FabricpathGlobal.fabricpath_feature_set(:disabled)
    end

    def my_munge(property, set_val)
      val = config_get_default('fabricpath', property)
      case property
      when /loadbalance_algorithm/
        if (val == 'source-destination') &&
           (set_val == 'symmetric' || set_val == 'xor')
          val
        else
          set_val
        end
      when /loadbalance_.*_rotate/
        if val == false || set_val == ''
          ''
        else
          "rotate-amount 0x#{set_val.to_s(16)}"
        end
      else
        set_val
      end
    end

    ########################################################
    #                      PROPERTIES                      #
    ########################################################

    def aggregate_multicast_routes
      config_get('fabricpath', 'aggregate_multicast_routes')
    end

    def aggregate_multicast_routes=(val)
      @set_params = {}
      @set_params[:state] = val ? '' : 'no'
      config_set('fabricpath', 'aggregate_multicast_routes', @set_params)
    rescue Cisco::CliError => e
      raise "[Setting agg-routes #{val}] '#{e.command}' : #{e.clierror}"
    end

    def default_aggregate_multicast_routes
      config_get_default('fabricpath', 'aggregate_multicast_routes')
    end

    def allocate_delay
      config_get('fabricpath', 'allocate_delay')
    end

    def allocate_delay=(val)
      @set_params = {}
      @set_params[:state] = val ? '' : 'no'
      @set_params[:delay] = val ? val : ''
      config_set('fabricpath', 'allocate_delay', @set_params)
    rescue Cisco::CliError => e
      raise "[Setting allocate-delay #{val}] '#{e.command}' : #{e.clierror}"
    end

    def default_allocate_delay
      config_get_default('fabricpath', 'allocate_delay')
    end

    def auto_switch_id
      config_get('fabricpath', 'auto_switch_id')
    end

    def graceful_merge
      graceful_merge_conf = config_get('fabricpath', 'graceful_merge')
      # opposite meaning with the cli
      return true if graceful_merge_conf.nil?
      graceful_merge_conf ? false : true
    end

    def graceful_merge=(val)
      @set_params = {}
      if val == '' || val == true
        @set_params[:state] = 'no'
      else
        @set_params[:state] = ''
      end
      config_set('fabricpath', 'graceful_merge', @set_params)
    rescue Cisco::CliError => e
      raise "[Setting allocate-delay #{val}] '#{e.command}' : #{e.clierror}"
    end

    def default_graceful_merge
      config_get_default('fabricpath', 'graceful_merge')
    end

    def linkup_delay
      config_get('fabricpath', 'linkup_delay')
    end

    def linkup_delay=(val)
      @set_params = {}
      @set_params[:state] = val ? '' : 'no'
      @set_params[:delay] = val ? val : ''
      config_set('fabricpath', 'linkup_delay', @set_params)
    rescue Cisco::CliError => e
      raise "[Setting linkup-delay #{val}] '#{e.command}' : #{e.clierror}"
    end

    def default_linkup_delay
      config_get_default('fabricpath', 'linkup_delay')
    end

    def linkup_delay_always
      config_get('fabricpath', 'linkup_delay_always')
    end

    def linkup_delay_always=(val)
      @set_params = {}
      if val == '' || val == true
        @set_params[:state] = ''
      else
        @set_params[:state] = 'no'
      end
      config_set('fabricpath', 'linkup_delay_always', @set_params)
    rescue Cisco::CliError => e
      raise "[Setting linkup-delay-always #{val}] '#{e.command}'
            : #{e.clierror}"
    end

    def default_linkup_delay_always
      config_get_default('fabricpath', 'linkup_delay_always')
    end

    def linkup_delay_enable
      delay = config_get('fabricpath', 'linkup_delay_enable')
      return false if delay.nil?
      delay
    end

    def linkup_delay_enable=(val)
      @set_params = {}
      if val == '' || val == true
        @set_params[:state] = ''
      else
        @set_params[:state] = 'no'
      end
      config_set('fabricpath', 'linkup_delay_enable', @set_params)
    rescue Cisco::CliError => e
      raise "[Setting linkup-delay-enable #{val}] '#{e.command}'
            : #{e.clierror}"
    end

    def default_linkup_delay_enable
      config_get_default('fabricpath', 'linkup_delay_enable')
    end

    def loadbalance_algorithm
      algo = config_get('fabricpath', 'loadbalance_algorithm')
      algo.downcase
    end

    def loadbalance_algorithm=(val)
      @set_params = {}
      val = my_munge('loadbalance_algorithm', val)
      @set_params[:state] = val ? '' : 'no'
      @set_params[:algo] = val ? val : ''
      config_set('fabricpath', 'loadbalance_algorithm', @set_params)
    rescue Cisco::CliError => e
      raise "[Setting loadbalance-algo #{val}] '#{e.command}' : #{e.clierror}"
    end

    def default_loadbalance_algorithm
      config_get_default('fabricpath', 'loadbalance_algorithm')
    end

    def loadbalance_multicast_rotate
      config_get('fabricpath', 'loadbalance_multicast_rotate')
    end

    def loadbalance_multicast_has_vlan
      config_get('fabricpath', 'loadbalance_multicast_has_vlan')
    end

    def loadbalance_multicast=(rotate, has_vlan)
      if rotate == '' && (has_vlan == '' || has_vlan == false)
        config_set('fabricpath', 'loadbalance_multicast_reset')
      else
        rotate = my_munge('loadbalance_multicast_rotate', rotate)
        has_vlan = (has_vlan == true) ? 'include-vlan' : ''
        config_set('fabricpath', 'loadbalance_multicast_set',
                   rotate_amt: rotate, inc_vlan: has_vlan)
      end
    rescue Cisco::CliError => e
      raise "[Setting loadbalance #{rotate} #{has_vlan}] '#{e.command}'
             : #{e.clierror}"
    end

    def default_loadbalance_multicast_rotate
      config_get_default('fabricpath', 'loadbalance_multicast_rotate')
    end

    def default_loadbalance_multicast_has_vlan
      config_get_default('fabricpath', 'loadbalance_multicast_has_vlan')
    end

    def loadbalance_unicast_layer
      unicast = config_get('fabricpath', 'loadbalance_unicast_layer')
      return default_loadbalance_unicast_layer if unicast.nil?
      case unicast
      when /L4/
        'layer4'
      when /L3/
        'layer3'
      when /Mixed/
        'mixed'
      end
    end

    def loadbalance_unicast_rotate
      config_get('fabricpath', 'loadbalance_unicast_rotate')
    end

    def loadbalance_unicast_has_vlan
      config_get('fabricpath', 'loadbalance_unicast_has_vlan')
    end

    def split_loadbalance_unicast_layer=(val)
      @set_params = {}
      @set_params[:state] = val ? '' : 'no'
      @set_params[:pref] = val ? val : ''
      config_set('fabricpath', 'loadbalance_unicast_layer', @set_params)
    rescue Cisco::CliError => e
      raise "[Setting loadbalance layer #{val} ] '#{e.command}'
            : #{e.clierror}"
    end

    def split_loadbalance_unicast_has_vlan=(val)
      @set_params = {}
      if val == '' || val == false
        @set_params[:state] = 'no'
      else
        @set_params[:state] = ''
      end
      config_set('fabricpath', 'loadbalance_unicast_has_vlan', @set_params)
    rescue Cisco::CliError => e
      raise "[Setting loadbalance has_vlan #{val} ] '#{e.command}'
            : #{e.clierror}"
    end

    def loadbalance_unicast=(layer, rotate, has_vlan)
      support = config_get('fabricpath', 'loadbalance_unicast_support')
      if support == 'combined'
        if layer == '' && rotate == '' && (has_vlan == '' || has_vlan == false)
          config_set('fabricpath', 'loadbalance_unicast_reset')
        else
          rotate = my_munge('loadbalance_unicast_rotate', rotate)
          has_vlan = (has_vlan == true) ? 'include-vlan' : ''
          config_set('fabricpath', 'loadbalance_unicast_set',
                     pref: layer, rotate_amt: rotate, inc_vlan: has_vlan)
        end
      else
        self.split_loadbalance_unicast_layer = layer
        self.split_loadbalance_unicast_has_vlan = has_vlan
      end
    rescue Cisco::CliError => e
      raise "[Setting loadbalance #{layer} #{rotate} #{has_vlan}] '#{e.command}'
            : #{e.clierror}"
    end

    def default_loadbalance_unicast_layer
      config_get_default('fabricpath', 'loadbalance_unicast_layer')
    end

    def default_loadbalance_unicast_rotate
      config_get_default('fabricpath', 'loadbalance_unicast_rotate')
    end

    def default_loadbalance_unicast_has_vlan
      config_get_default('fabricpath', 'loadbalance_unicast_has_vlan')
    end

    def mode
      config_get('fabricpath', 'mode')
    end

    def mode=(val)
      @set_params = {}
      if val == '' || val == 'normal'
        @set_params[:state] = 'no'
      else
        @set_params[:state] = ''
      end
      config_set('fabricpath', 'mode', @set_params)
    rescue Cisco::CliError => e
      raise "[Setting mode #{val}] '#{e.command}' : #{e.clierror}"
    end

    def default_mode
      config_get_default('fabricpath', 'mode')
    end

    def switch_id
      switch_id_conf = config_get('fabricpath', 'switch_id')
      return auto_switch_id if switch_id_conf.nil?
      switch_id_conf
    end

    def switch_id=(val)
      # There is no no-form for this command
      config_set('fabricpath', 'switch_id', swid: val.to_s)
    rescue Cisco::CliError => e
      raise "[Setting switch-id #{val}] '#{e.command}' : #{e.clierror}"
    end

    def transition_delay
      config_get('fabricpath', 'transition_delay')
    end

    def transition_delay=(val)
      @set_params = {}
      @set_params[:state] = val ? '' : 'no'
      @set_params[:delay] = val ? val : ''
      config_set('fabricpath', 'transition_delay', @set_params)
    rescue Cisco::CliError => e
      raise "[Setting transition_delay #{val}] '#{e.command}' : #{e.clierror}"
    end

    def default_transition_delay
      config_get_default('fabricpath', 'transition_delay')
    end

    def ttl_multicast
      config_get('fabricpath', 'ttl_multicast')
    end

    def ttl_multicast=(val)
      @set_params = {}
      @set_params[:state] = val ? '' : 'no'
      @set_params[:ttl] = val ? val : ''
      config_set('fabricpath', 'ttl_multicast', @set_params)
    rescue Cisco::CliError => e
      raise "[Setting ttl_multicast #{val}] '#{e.command}' : #{e.clierror}"
    end

    def default_ttl_multicast
      config_get_default('fabricpath', 'ttl_multicast')
    end

    def ttl_unicast
      config_get('fabricpath', 'ttl_unicast')
    end

    def ttl_unicast=(val)
      @set_params = {}
      @set_params[:state] = val ? '' : 'no'
      @set_params[:ttl] = val ? val : ''
      config_set('fabricpath', 'ttl_unicast', @set_params)
    rescue Cisco::CliError => e
      raise "[Setting ttl_unicast #{val}] '#{e.command}' : #{e.clierror}"
    end

    def default_ttl_unicast
      config_get_default('fabricpath', 'ttl_unicast')
    end
  end # class
end # module
