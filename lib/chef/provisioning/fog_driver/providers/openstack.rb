# fog:OpenStack:https://identifyhost:portNumber/v2.0
class Chef
module Provisioning
module FogDriver
  module Providers
    class OpenStack < FogDriver::Driver

      Driver.register_provider_class('OpenStack', FogDriver::Providers::OpenStack)

      def creator
        compute_options[:openstack_username]
      end
      
      def bootstrap_options_for(action_handler, machine_spec, machine_options)
        bootstrap_options = symbolize_keys(machine_options[:bootstrap_options] || {})

        bootstrap_options[:tags]  = default_tags(machine_spec, bootstrap_options[:tags] || {})

        bootstrap_options[:name] ||= machine_spec.name
        
        if !bootstrap_options[:flavor_ref] && bootstrap_options[:flavor_name]
          bootstrap_options[:flavor_ref] = compute.flavors.flavors.detect { |f| f.name == bootstrap_options[:flavor_name] }.id
        end
        
        if !bootstrap_options[:image_ref] && bootstrap_options[:image_name]
          bootstrap_options[:image_ref] = image.images.detect { |i| i.name == bootstrap_options[:image_name] }.id
        end
        
        bootstrap_options
      end
      
      def image
        @image ||= Fog::Image.new(compute_options)
      end

      def self.compute_options_for(provider, id, config)
        new_compute_options = {}
        new_compute_options[:provider] = provider
        new_config = { :driver_options => { :compute_options => new_compute_options }}
        new_defaults = {
          :driver_options => { :compute_options => {} },
          :machine_options => { :bootstrap_options => {} }
        }
        
        result = Cheffish::MergedConfig.new(new_config, config, new_defaults)

        new_compute_options[:openstack_auth_url] = id if (id && id != '')
        credential = Fog.credentials

        new_compute_options[:openstack_username] ||= credential[:openstack_username]
        new_compute_options[:openstack_api_key] ||= credential[:openstack_api_key]
        new_compute_options[:openstack_auth_url] ||= credential[:openstack_auth_url]
        new_compute_options[:openstack_tenant] ||= credential[:openstack_tenant]

        id = result[:driver_options][:compute_options][:openstack_auth_url]

        [result, id]
      end

    end
  end
end
end
end
