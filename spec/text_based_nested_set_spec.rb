require 'spec_helper'

describe 'TextBasedNestedSet' do
  before :each do
    # test tree:
    # root(1)
    #  |__child_1(2)
    #  |     |__child_1_1(4)
    #  |     |     |__child_1_1_1(7)
    #  |     |__child_1_2(6)
    #  |     |     |__child_1_2_1(3)
    #  |     |__child_1_3(5)
    #  |__child_2(8) 
    @root = create(:category, id: 1, parent_id: 0, path: "/0/", position: 0)
    @child_1 = create(:category, id: 2, name: "child_1", parent_id: 1, path: "/0/1/", position: 0)
    @child_2 = create(:category, id: 8, name: "child_2", parent_id: 1, path: "/0/1/", position: 1)
    @child_1_1 = create(:category, id: 4, name: "child_1_1", parent_id: 2, path: "/0/1/2/", position: 0)    
    @child_1_2 = create(:category, id: 6, name: "child_1_2", parent_id: 2, path: "/0/1/2/", position: 1)
    @child_1_3 = create(:category, id: 5, name: "child_1_3", parent_id: 2, path: "/0/1/2/", position: 2)
    @child_1_1_1 = create(:category, id: 7, name: "child_1_1_1", parent_id: 4, path: "/0/1/2/4/", position: 0)	
    @child_1_2_1 = create(:category, id: 3, name: "child_1_2_1", parent_id: 6, path: "/0/1/2/6/", position: 0)
  end

  describe 'move_to_root' do
    it 'should move to the root of the tree' do
      @child_1_2.move_to_root
      @child_1_2.reload
      @child_1_1.reload
      @child_1_3.reload
      @child_1_2_1.reload
      expect(@child_1_2.path).to eq("/0/")
      expect(@child_1_2.parent_id).to eq(0)
      expect(@child_1_2.position).to eq(0)
      expect(@child_1_1.position).to eq(0)
      expect(@child_1_3.position).to eq(1)
      expect(@child_1_2_1.path).to eq("/0/6/")
      expect(@child_1.descendants).to eq([@child_1_1, @child_1_3, @child_1_1_1])
    end
  end

  describe 'move_to_left_of' do
    it 'should move to the left of target node' do
      @child_1_2.move_to_left_of(@child_2)

      @child_1_2.reload
      @child_2.reload
      @child_1_3.reload
      @child_1_2_1.reload
      expect(@child_1_2.path).to eq('/0/1/')
      expect(@child_1_2.position).to eq(1)
      expect(@child_2.position).to eq(2)
      expect(@child_1_3.position).to eq(1)
      expect(@child_1_2_1.path).to eq('/0/1/6/')
    end
  end

  describe 'move_to_right_of' do
    it 'should move to the right of target node' do
      @child_1_1.move_to_right_of(@child_1)

      @child_1_1.reload
      @child_2.reload
      @child_1_2.reload
      @child_1_3.reload
      expect(@child_1_1.path).to eq('/0/1/')
      expect(@child_1_1.position).to eq(1)
      expect(@child_2.position).to eq(2)
      expect(@child_1_2.position).to eq(0)
      expect(@child_1_3.position).to eq(1)
    end
  end

  describe 'move_to_child_of' do
    it 'should move to the child of target node' do
      @child_1_2.move_to_child_of(@child_1_1)

      @child_1_2.reload
      @child_1_3.reload
      @child_1_2_1.reload
      expect(@child_1_2.path).to eq('/0/1/2/4/')
      expect(@child_1_2.position).to eq(1)
      expect(@child_1_3.position).to eq(1)
      expect(@child_1_2_1.path).to eq('/0/1/2/4/6/')
    end
  end

  describe 'parent' do
    it "should return current node's parent node" do
      expect(@child_1_1.parent.name).to eq("child_1")
    end

    it "should return nil when current node is root node" do
      expect(@root.parent).to eq(nil)
    end
  end

  describe 'ancestors' do
    it "should return current node's ancestors node" do
      expect(@child_1_1.ancestors).to eq([@root, @child_1])
    end
  end

  describe 'self_and_ancestors' do
    it "should return current node's ancestors node include self" do
      expect(@child_1_1.self_and_ancestors).to eq([@root, @child_1, @child_1_1])
    end
  end

  describe 'children' do
    it "should return current node's children node" do
      expect(@child_1.children).to eq([@child_1_1, @child_1_2, @child_1_3])
    end
  end

  describe 'descendants' do
    it "should return current node's all descendants" do
      expect(@child_1.descendants).to eq([@child_1_1, @child_1_2, @child_1_3, @child_1_2_1, @child_1_1_1])
      expect(@root.descendants).to eq([@child_1, @child_2, @child_1_1, @child_1_2, @child_1_3, @child_1_2_1, @child_1_1_1])
    end
  end

  describe 'right_sibling' do
    it "should return current node's right sibling" do
      expect(@child_1_2.right_sibling).to eq(@child_1_3)
    end

    it "should return nil when current node's right sibling is not existed" do
      expect(@child_1_3.right_sibling).to eq(nil)
    end
  end

  describe 'left_sibling' do
    it "should return current node's left sibling" do
      expect(@child_1_2.left_sibling).to eq(@child_1_1)
    end

    it "should return nil when current node's left sibling is not existed" do
      expect(@child_1_1.left_sibling).to eq(nil)
    end
  end

  describe 'root?' do
    it "should return true if current node is root node" do
      expect(@root.root?).to eq(true)
    end

    it "should return false if current node is not root node" do
      expect(@child_1.root?).to eq(false)
    end
  end

  describe 'convert_from_awesome_nested_set' do
    it "should convert awesome nested set to text based nested set" do
      @root.update(parent_id: nil)
      @root.reload
      Category.convert_from_awesome_nested_set
      expect(@root.path).to eq('/0/')
    end
  end

  describe 'rebuild' do
    it "should rebuild current node's all descendants, set path and position again " do
      @root.descendants.each do |d|
        d.update(path: nil, position: nil)
      end
      @root.update(path: nil, position: nil)
      @root.reload
      @child_1.reload
      @child_1_1.reload
      @child_1_1_1.reload
      @child_1_2.reload
      @child_1_2_1.reload
      @child_1_3.reload
      @child_2.reload

      @root.rebuild

      @root.reload
      @child_1.reload
      @child_1_1.reload
      @child_1_1_1.reload
      @child_1_2.reload
      @child_1_2_1.reload
      @child_1_3.reload
      @child_2.reload

      expect(@child_1.path).to eq('/0/1/')
      expect(@child_1.position).to eq(0)
      expect(@child_1_1_1.path).to eq('/0/1/2/4/')
    end
  end

  describe 'private destroy_descendants' do
    it 'should destroy descendants when itself be destroyed' do
      @child_1.destroy
      expect(Category.find_by_id(4)).to eq(nil)
      expect(Category.find_by_id(8).name).to eq('child_2')
    end
  end

  describe 'default value test' do
    it 'should create a root node' do
      root1 = create(:category, name: 'root1')
      expect(root1.parent_id).to eq(0)
      expect(root1.path).to eq('/0/')
      expect(root1.position).to eq(0)
    end
  end
end
