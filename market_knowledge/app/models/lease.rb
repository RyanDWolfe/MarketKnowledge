class Lease < ApplicationRecord
    belongs_to :property

  # Generate a CSV File of All Lease Records
  def self.to_csv(fields = column_names, options={})
  CSV.generate(options) do |csv|      
          csv << fields
          all.each do |lease|
              csv << lease.attributes.values_at(*fields)
          end
      end
  end

# Import CSV, Find or Create Lease by its tenant.
# A tenant might have multiple leases which would cause an issue, look for a different field
# Update the record.
  def self.import(file)
    CSV.foreach(file.path, headers: true) do |row|
      leases_hash = row.to_hash
      lease = find_or_create_by!(tenant: leases_hash['tenant'])
      lease.update_attributes(leases_hash)
    end
  end

  def self.search(search)
    if search
      if search != ""
        @leases = Lease.where(tenant: search)
      else
        @leases = Lease.all
      end
    else
      @leases = Lease.all
    end
  end

  def self.filter(filter)
    type = filter.keys[0]
    value = filter[type]
    case type
      when ""
        @leases = Lease.all
      when "submarket"
        @property_ids = []
        @properties = Property.where(submarket: value)
        @properties.each do |property|
          @property_ids << property.id
        end
        @leases = Lease.where(property_id: @property_ids)
      else
        @leases = Lease.all
    end
  end



end