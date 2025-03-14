<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Audit extends Model
{
    public function getModified(): array
    {
        $oldValues = json_decode($this->old_values, true) ?? [];
        $newValues = json_decode($this->new_values, true) ?? [];

        $modifiedAttributes = array_unique(array_merge(array_keys($oldValues), array_keys($newValues)));

        $modified = [];
        foreach ($modifiedAttributes as $attribute) {
            $modified[$attribute] = [
                'old' => $oldValues[$attribute] ?? null,
                'new' => $newValues[$attribute] ?? null,
            ];
        }

        return $modified;
    }
}
