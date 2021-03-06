module Dase
  module PreloaderMethods

    def initialize(klass, owners, reflection, preload_options)
      # grabbing our options
      preload_options = preload_options.clone
      @dase_association = preload_options.delete(:association)
      @dase_counter_name = preload_options.delete(:as)
      @dase_scope_to_merge = preload_options.delete(:only)
      #@dase_proc = preload_options.delete(:proc)
      super(klass, owners, reflection, preload_options)
    end

    def prefixed_foreign_key
      "#{scoped.quoted_table_name}.#{reflection.foreign_key}"
    end

    def preload
      pk = model.primary_key.to_sym
      ids = owners.map(&pk)
      scope = records_for(ids)
      scope = scope.merge(@dase_scope_to_merge) if @dase_scope_to_merge
      #if @dase_proc # support for includes_count_of(...){ where(...) } syntax
      #  case @dase_proc.arity
      #    when 0
      #      scope = scope.instance_eval &@dase_proc
      #    when 1
      #      scope = @dase_proc.call(scope)
      #    else
      #      raise ArgumentError, "The block passed to includes_count_of takes 0 or 1 arguments"
      #  end
      #end
      counters_hash = scope.count(:group => prefixed_foreign_key)
      owners.each do |owner|
        value = counters_hash[owner[pk]] || 0 # 0 is "default count", when no records found
        owner.set_dase_counter(@dase_counter_name, value)
      end
    end

  end
end