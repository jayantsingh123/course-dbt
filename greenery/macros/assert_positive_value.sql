{% test assert_positive_value(model, column_name) %}

    select *
    from {{ model }}
    where {{ column_name }} < 0

{% endtest %}