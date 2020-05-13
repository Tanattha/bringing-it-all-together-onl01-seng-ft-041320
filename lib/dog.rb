class Dog
    attr_accessor :id, :name, :breed

    def initialize(id:nil, name:, breed:)
        @id = id
        @name = name
        @breed = breed
    end

    def self.create_table
        sql = "CREATE TABLE IF NOT EXISTS dogs 
        (id INTEGER PRIMARY KEY,
        name TEXT,
        breed TEXT)"

        DB[:conn].execute(sql)
    end

    def self.drop_table
        sql = "DROP TABLE IF EXISTS dogs"
        DB[:conn].execute(sql)
    end

#returns an instance of the dog class
#saves an instance of the dog class to the database 
#and then sets the given dogs `id` attribute
    def save
        sql = "INSERT INTO dogs (name, breed) VALUES (?, ?)"
        
        DB[:conn].execute(sql, self.name, self.breed)
        @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
        self
    end

#takes in a hash of attributes and uses metaprogramming 
#to create a new dog object. Then it uses the #save method 
#to save that dog to the database
    def self.create(name:, breed:)
        dog = Dog.new(name: name, breed: breed)
        dog.save
        dog
    end

#creates an instance with corresponding attribute values
    def self.new_from_db(row)
        id = row[0]
        name = row[1]
        breed = row[2]
        self.new(id: id, name: name, breed: breed)
    end

#returns a new dog object by id
    def self.find_by_id(id)
        sql = "SELECT *
        FROM dogs
        WHERE id = ?
        LIMIT 1"

        DB[:conn].execute(sql,id).map do |row|
        self.new_from_db(row)
        end.first
    end

#returns an instance of dog that matches the name from the DB
    def self.find_by_name(name)
        sql = "SELECT *
        FROM dogs
        WHERE name = ?
        LIMIT 1"

        DB[:conn].execute(sql,name).map do |row|
        self.new_from_db(row)
        end.first
    end

#updates the record associated with a given instance
    def update
        sql = "UPDATE dogs SET name = ?, breed = ?  WHERE id = ?"
        DB[:conn].execute(sql, self.name, self.breed, self.id)
    end

#creates an instance of a dog if it does not already exist
#when two dogs have the same name and different breed, 
#it returns the correct dog
#when creating a new dog with the same name as persisted dogs,
#it returns the correct dog
    def self.find_or_create_by(name:, breed:)
        sql = "SELECT *
              FROM dogs
              WHERE name = ?
              AND breed = ?
              LIMIT 1"
    
        dog = DB[:conn].execute(sql,name,breed)
    
        if dog != []
          find_dog = dog[0]
          dog = Dog.new(id: find_dog[0], name: find_dog[1], breed: find_dog[2])
        else
          dog = self.create(name: name, breed: breed)
        end
        dog
      end
end