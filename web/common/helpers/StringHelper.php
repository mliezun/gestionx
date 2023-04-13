<?php

namespace common\helpers;

class StringHelper
{
    /**
     * determines if a string ends with a substring
     *
     * @param haystack
     * @param needle
     */
    public static function endsWith($haystack, $needle)
    {
        $length = strlen($needle);
        if (!$length) {
            return true;
        }
        return substr($haystack, -$length) === $needle;
    }

    /**
     * determines if a string starts with a substring
     *
     * @param haystack
     * @param needle
     */
    public static function startsWith($haystack, $needle)
    {
        $length = strlen($needle);
        return substr($haystack, 0, $length) === $needle;
    }
}
