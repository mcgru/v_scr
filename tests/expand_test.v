module v_scr_test

import v_scr

fn test_expand_parameter_expansion_default() {
    // ${VAR:-default} - use default if unset or empty
    result := v_scr.new_list(
        v_scr.echo(r'${UNSET_VAR:-default_value}'),
    ).exec() or { panic(err) }

    assert result.trimmed_string() == 'default_value'

    result_with_value := v_scr.new_list(
        v_scr.local_('NAME', 'actual'),
        v_scr.echo(r'${NAME:-default}'),
    ).exec() or { panic(err) }

    assert result_with_value.trimmed_string() == 'actual'
}

fn test_expand_parameter_expansion_plus() {
    // ${VAR:+value} - use value if set
    result_unset := v_scr.new_list(
        v_scr.echo(r'${UNSET_VAR:+alternate}'),
    ).exec() or { panic(err) }

    assert result_unset.trimmed_string() == ''

    result_set := v_scr.new_list(
        v_scr.local_('NAME', 'value'),
        v_scr.echo(r'${NAME:+alternate}'),
    ).exec() or { panic(err) }

    assert result_set.trimmed_string() == 'alternate'
}

fn test_expand_parameter_expansion_length() {
    // ${#VAR} - string length
    result := v_scr.new_list(
        v_scr.local_('NAME', 'hello'),
        v_scr.echo(r'${#NAME}'),
    ).exec() or { panic(err) }

    assert result.trimmed_string() == '5'
}

fn test_expand_parameter_expansion_case() {
    // ${VAR^^} - uppercase, ${VAR,,} - lowercase
    upper_result := v_scr.new_list(
        v_scr.local_('name', 'hello'),
        v_scr.echo(r'${name^^}'),
    ).exec() or { panic(err) }

    lower_result := v_scr.new_list(
        v_scr.local_('NAME', 'WORLD'),
        v_scr.echo(r'${NAME,,}'),
    ).exec() or { panic(err) }

    assert upper_result.trimmed_string() == 'HELLO'
    assert lower_result.trimmed_string() == 'world'
}

fn test_expand_parameter_expansion_substring() {
    // ${VAR:offset} - substring from offset
    substr_result := v_scr.new_list(
        v_scr.local_('TEXT', 'hello world'),
        v_scr.echo(r'${TEXT:6}'),
    ).exec() or { panic(err) }

    // ${VAR:offset:len} - substring with length
    substr_len_result := v_scr.new_list(
        v_scr.local_('TEXT', 'hello world'),
        v_scr.echo(r'${TEXT:0:5}'),
    ).exec() or { panic(err) }

    assert substr_result.trimmed_string() == 'world'
    assert substr_len_result.trimmed_string() == 'hello'
}
