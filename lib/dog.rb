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

    def save
        sql = "INSERT INTO dogs(name,breed) VALUES (?,?)"
        DB[:conn].execute(sql, self.name, self.breed)
        @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
        self
    end

    def self.create(name:,breed:)
        dog = Dog.new(name:name, breed:breed)
        dog.save
        dog
    end

    def self.new_from_db(row)
        new_dog = self.new(id: row[0],name: row[1], breed: row[2])
        new_dog
    end
    
    def self.find_by_id(id)
        sql = "SELECT * FROM dogs WHERE id = ? LIMIT 1"
           dogs_arr = DB[:conn].execute(sql,id).map do |row|
           self.new_from_db(row)
            end
        dogs_arr.first
    end
    
    def self.find_or_create_by(name:,breed:)
        sql = "SELECT * FROM dogs WHERE name = ? AND breed = ? LIMIT 1"
        dogs_arr = DB[:conn].execute(sql,name,breed)

        if dogs_arr.empty?
            dog = self.create({name: name, breed: breed})
        else
            find_dog = dogs_arr[0]
            dog = Dog.new(id: find_dog[0], name: find_dog[1], breed: find_dog[2])
        end
        dog
    end

    def self.find_by_name(name)
        sql = "SELECT * FROM dogs WHERE name = ? LIMIT 1"
        dogs_arr = DB[:conn].execute(sql,name).map do |row|
        self.new_from_db(row)
        end
        dogs_arr.first
    end

    def update
        sql = "UPDATE dogs SET name = ?, breed = ? WHERE id = ?"
        DB[:conn].execute(sql,self.name,self.breed,self.id)
    end

end