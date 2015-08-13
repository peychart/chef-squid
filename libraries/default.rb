# load them databags or values.
def printValues( name, val, indent=0 )
  ret = []
  if val.is_a? Hash
    val.each do |n, v|
      printValues( n, v, indent+1 ).each do |s|; ret << s; end
    end
  elsif val.is_a? Array
    val.each do |v|
      ret.push( String("  " * indent) + name + ' ' + v ) if name != 'id'
    end
  else
    ret.push( String("  " * indent) + name + ' ' + val ) if name != 'id' && val
  end
  ret
end

def printDefinitions( definitions, type, name )
  ret = []
  if name != ''
    ret.push( '  ' + name + ' {' )
    printValues( name, definitions[name], 1 ).each do |s|; ret << s; end
    ret.push( '  }' )
    ret.push( '' )
  else
    definitions.each do |n, val|
      if n != 'default'
        ret.push( (type=='acl'? '  ' : type + ' ') + n + ' {' )
        printValues( n, val, type=='acl'?1:0 ).each do |s|; ret << s; end
        ret.push( type=='acl'?'  }':'}' )
        ret.push( '' )
      end
    end
  end
  ret
end

def chef_squidGuard_load_values( d, type, name='' )
  definitions = {}
  begin
    data_bag( d[type]['databag_name'] ).each do |bag|
      data_bag_item( d[type]['databag_name'], bag ).each do |n, v|
        if n != 'id'
          if ! definitions
            definitions = {bag => {n => v}}
          elsif ! definitions[bag]
            definitions.store( bag, {n => v} )
          else
            definitions[bag].store(n, v)
          end
        end
      end
    end
  rescue
    Chef::Log.info "no '#{d[type]['databag_name']}' data bag"
  end
  printDefinitions( definitions, type, name ) if definitions && definitions.any?
end

