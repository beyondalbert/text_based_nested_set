module BeyondAlbert
  module Acts
    module TextBasedNestedSet
      module Model
        extend ActiveSupport::Concern

        included do
        end

        module ClassMethods
          def convert_from_awesome_nested_set
            root_nodes = where(parent_id: nil)
            root_nodes.each do |r|
              r.update(parent_id: 0, path: '/0/')
              r.rebuild
            end
          end
        end

        def move_to_root
          in_tenacious_transaction do
            # reset siblings' position
            self.siblings.each do |s|
              if s.position > self.position
                s.position -= 1
                s.save!
              end
            end

            descendants = self.descendants

            self.update(parent_id: 0, path: '/0/', position: 0)

            # reset descendants' path
            descendants.each do |d|
              d.path = d.parent.path + d.parent_id.to_s + '/'
              d.save!
            end

          end
        end

        def move_to_left_of(target)
          in_tenacious_transaction do
            descendants = self.descendants

            # set new siblings's position
            target.self_and_siblings.each do |s|
              if s.position >= target.position
                s.position += 1
                s.save!
              end
            end
            target.reload

            # set old siblings's position
            self.siblings.each do |s|
              if s.position > self.position
                s.position -= 1
                s.save!
              end
            end

            # set self attributes 
            self.update(path: target.path, parent_id: target.parent_id, position: target.position - 1)

            # set descendants' path
            descendants.each do |d|
              d.path = d.parent.path + d.parent_id.to_s + '/'
              d.save!
            end
          end
        end

        def move_to_right_of(target)
          in_tenacious_transaction do
            descendants = self.descendants

            # set new siblings' position
            target.self_and_siblings.each do |s|
              if s.position > target.position
                s.position += 1
                s.save!
              end
            end

            # set old siblings' position
            self.siblings.each do |s|
              if s.position > self.position
                s.position -= 1
                s.save!
              end
            end

            # set self attributes
            self.update(path: target.path, parent_id: target.parent_id, position: target.position + 1)

            # set descendants' path
            descendants.each do |d|
              d.path = d.parent.path + d.parent_id.to_s + '/'
              d.save!
            end
          end
        end

        def move_to_child_of(target)
          in_tenacious_transaction do
            descendants = self.descendants

            # set old siblings' position
            self.siblings.each do |s|
              if s.position > self.position
                s.position -= 1
                s.save!
              end
            end

            # set self attributes
            self.update(path: target.path + target.id.to_s + '/', parent_id: target.id, position: target.children.size)

            # set descendants' path
            descendants.each do |d|
              d.path = d.parent.path + d.parent_id.to_s + '/'
              d.save!
            end
          end
        end

        def parent
          if self.root?
            nil
          else
            current_class.find(self.parent_id)
          end
        end

        def ancestors
          parent_ids = self.path.split('/').select {|v| v != "" && v != "0"}
          current_class.where(id: parent_ids)
        end

        def self_and_ancestors
          ancestors << self
        end

        def children
          children_path = self.path + self.id.to_s + '/'
          current_class.where(path: children_path).order('position')
        end

        def descendants
          descendants_path = self.path + self.id.to_s + '/%'
          current_class.where("path LIKE ?", descendants_path).order("LENGTH(path) ASC, position ASC")
        end

        def self_and_descendants
          descendants.unshift(self)
        end

        def right_sibling
          right_siblings = current_class.where(path: self.path, position: self.position + 1)
          if right_siblings.empty?
            nil
          else
            right_siblings.first
          end
        end

        def left_sibling
          left_siblings = current_class.where(path: self.path, position: self.position - 1 )
          if left_siblings.empty?
            nil
          else
            left_siblings.first
          end
        end

        def siblings
          current_class.where(path: self.path).select {|o| o.id != self.id}
        end

        def self_and_siblings
          current_class.where(path: self.path)
        end

        def root?
          self.parent_id == 0
        end

        def rebuild
          in_tenacious_transaction do
            children = current_class.where(parent_id: self.id)
            if self.parent_id == 0
              self.update!(path: '/0/')
            end
            unless children.empty?
              children.each.with_index do |c, index|
                c.update(path: self.path + self.id.to_s + '/', position: index)
                c.rebuild
              end
            end
          end
        end

        private

        def in_tenacious_transaction(&block)
          retry_count = 0
          begin
            transaction(&block)
          rescue ActiveRecord::StatementInvalid => error
            raise unless connection.open_transactions.zero?
            raise unless error.message =~ /Deadlock found when trying to get lock|Lock wait timeout exceeded/
            raise unless retry_count < 10
            retry_count += 1
            logger.info "Deadlock detected on retry #{retry_count}, restarting transaction"
            sleep(rand(retry_count)*0.1) # Aloha protocol
            retry
          end
        end

        def current_class
          self.class.base_class
        end

        def destroy_descendants
          self.descendants.destroy_all
        end
      end
    end
  end
end
