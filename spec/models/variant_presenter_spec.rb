require 'rails_helper'

RSpec.describe VariantPresenter do
  let(:split) { FactoryGirl.create(:split, name: "some_feature_enabled", registry: { true: 40, false: 60 }) }

  describe "#weight" do
    subject { described_class.new(VariantDetail.new(split: split, variant: 'true')) }

    it "is the weight of the given variant" do
      expect(subject.weight).to eq 40
    end
  end

  describe "#assignment_count" do
    let!(:true_assignment) { FactoryGirl.create(:assignment, split: split, variant: "true") }
    let!(:false_assignment) { FactoryGirl.create_pair(:assignment, split: split, variant: "false") }

    let(:true_presenter) { described_class.new(VariantDetail.new(split: split, variant: 'true')) }
    let(:false_presenter) { described_class.new(VariantDetail.new(split: split, variant: 'false')) }

    it "is the number of assignments of given variant" do
      expect(true_presenter.assignment_count).to eq 1
      expect(false_presenter.assignment_count).to eq 2
    end
  end

  describe "#retirable?" do
    subject { described_class.new(VariantDetail.new(split: split, variant: 'true')) }

    context 'with a 0% weight' do
      let(:split) { FactoryGirl.create(:split, name: "some_feature_enabled", registry: { true: 0, false: 100 }) }

      context 'with no assignments' do
        it "is false" do
          expect(subject).not_to be_retirable
        end
      end

      context 'with some assignments' do
        let!(:assignment) { FactoryGirl.create(:assignment, split: split, variant: "true") }

        it "is true" do
          expect(subject).to be_retirable
        end
      end
    end

    context 'with a non-0% weight' do
      let(:split) { FactoryGirl.create(:split, name: "some_feature_enabled", registry: { true: 1, false: 99 }) }

      context 'with no assignments' do
        it "is false" do
          expect(subject).not_to be_retirable
        end
      end

      context 'with some assignments' do
        let!(:assignment) { FactoryGirl.create(:assignment, split: split, variant: "true") }

        it "is false for a non 0% weight that has assignments" do
          expect(subject).not_to be_retirable
        end
      end
    end
  end
end
