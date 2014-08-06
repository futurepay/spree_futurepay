Deface::Override.new(:virtual_path => 'spree/admin/shared/_configuration_menu',
                     :name => 'add_futurepay_to_admin',
                     :insert_bottom => "[data-hook='admin_configurations_sidebar_menu']",
                     :text => %q{
                      <%= configurations_sidebar_menu_item Spree.t(:futurepay), admin_futurepay_index_path %>
                      }
                    )