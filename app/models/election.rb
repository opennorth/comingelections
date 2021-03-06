# coding: utf-8
require 'csv'

class Election < ActiveRecord::Base
  attr_accessor :scheduled

  before_validation :set_year, :set_end_date

  validates_presence_of :year, :start_date, :end_date, :jurisdiction, :election_type, :source
  validates_inclusion_of :jurisdiction, in: ['Canada'] + ComingElections::PROVINCES_AND_TERRITORIES
  validates_inclusion_of :election_type, in: ComingElections::ELECTION_TYPES
  validates_inclusion_of :scope, in: ComingElections::SCOPES, allow_blank: true
  validate :end_date_must_be_after_start_date

  rails_admin do
    list do
      field :jurisdiction
      field :election_type
      field :start_date
      field :division
      field :scope
      field :notes
    end
  end

  # @param [Range] range a range of dates
  def self.within(range)
    where(start_date: range)
  end

  # @param [Hash] attributes attributes
  def self.create_or_update(attributes)
    criteria = attributes.slice(:start_date, :jurisdiction, :election_type, :division)
    election = Election.where(criteria).first_or_initialize
    election.assign_attributes(attributes)
    election.save!
  end

  # @return [String] the list of elections as a CSV file
  def self.to_csv(elections = all)
    CSV.generate(row_sep: "\r\n") do |csv|
      csv << ['id', 'year', 'start_date', 'end_date', 'jurisdiction', 'division', 'election_type', 'scope', 'notes', 'source', 'scheduled']
      elections.each do |election|
        csv << election.attributes.values_at('id', 'year', 'start_date', 'end_date', 'jurisdiction', 'division', 'election_type', 'scope', 'notes', 'source') + [election.scheduled]
      end
    end
  end

private

  def set_year
    if start_date_changed?
      self.year = start_date.year
    end
  end

  def set_end_date
    if start_date_changed?
      if end_date.blank? || end_date == start_date_was
        self.end_date = start_date
      end
    end
  end

  def end_date_must_be_after_start_date
    if end_date? && start_date? && end_date < start_date
      errors.add(:end_date, 'must be after start date')
    end
  end
end
