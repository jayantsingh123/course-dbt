{%- macro event_type_cnt() -%}

{%-
  set event_types = ["checkout", "page_view", "package_shipped", "add_to_cart"]
  
-%}

  {%- for event_type in event_types %}
  sum(case when event_type = '{{ event_type }}' then 1 else 0 end) as {{ event_type }}_cnt
  {% if not loop.last %},{% endif %}
  {%- endfor %}

{%- endmacro %}